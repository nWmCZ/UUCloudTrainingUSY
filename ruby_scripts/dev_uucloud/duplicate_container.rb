require "uu_operation_registry"
require "io/console"
require "uu_os"
require 'optparse'

target_container_count = 2
require_different_hosts = nil
app_credentials_file = nil
dry_run = false

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} appDeploymentUri [targetSlot=PRODUCTION] [options]"

  opts.on("--count=COUNT", Integer, "Target slot count") do |value|
    target_container_count = value
  end

  opts.on("--[no-]require-different-hosts",
      "Each container must run on a different host. " \
      "For backward compatibility, the default is true for count == 2 " \
      "and false for count >= 3. Use with --dry-run to check if there " \
      "is enough free hosts."
  ) do |value|
    require_different_hosts = value
  end

  opts.on("--credentials=FILENAME", "Credentials file") do |value|
    app_credentials_file = value
  end

  opts.on("--dry-run", "Don't write any changes") do
    puts "Dry run: no changes will be written"
    dry_run = true
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
elsif ARGV.size > 2
  puts "\nInvalid arguments. Please see the usage below:\n"
  puts opts
  exit(1)
end

cloud_uri = 'ues:DTC-BT:DEMO'
app_deployment_uri = ARGV[0]
target_slot = ARGV[1]

if target_slot.nil? || target_slot.empty?
  target_slot = 'PRODUCTION'
elsif !['PRODUCTION', 'BETA'].include?(target_slot)
  raise %Q(Invalid "targetSlot" attribute. Attribute must be one of ['PRODUCTION', 'BETA'] or nil but was #{target_slot}.)
end
puts "Target slot: #{target_slot}"

if target_container_count < 2
  raise %Q(Invalid "targetContainerCount" attribute. Attribute must valid integer >= 2 or nil but was #{target_container_count}.)
end
puts "Target container count: #{target_container_count}"

if require_different_hosts.nil?
  # For backward compatibility
  require_different_hosts = target_container_count == 2
end
puts "Require different hosts? #{require_different_hosts.inspect}"

if app_credentials_file
  UU::OS::Security::Session.login(app_credentials_file)
else
  print "AccessCode 1: "
  access_code1 = STDIN.noecho(&:gets).chomp
  puts ("")
  print "AccessCode 2: "
  access_code2 = STDIN.noecho(&:gets).chomp
  puts ("")

  UU::OS::Security::Session.login(access_code1, access_code2)
end

def canonize_uri(uri)
  uri = UU::OS::UESURI.new(uri)
  result = UU::OS::UESURIBuilder.new
  uri.instance_variable_get(:@parts).each_with_index do |part, idx|
    if idx == 0
      raise ArgumentError.new("UESURI #{uri} is missing territory ID.") if part.id.nil?
      result.set_territory_id(part.id)
    elsif idx == 1
      raise ArgumentError.new("UESURI #{uri} is missing artifact ID.") if part.id.nil?
      result.set_artifact_id(part.id)
    elsif idx == 2
      raise ArgumentError.new("UESURI #{uri} is missing object ID.") if part.id.nil?
      result.set_object_id(part.id)
    else
      raise ArgumentError.new("UESURI #{uri} has too many elements.")
    end
  end
  result.to_uesuri
end

def get_node_size(cloud_uri, size_code)
  query = {code: size_code}.to_json
  node_sizes = UU::OperationRegistry::NodeSize.get_node_size_list(cloud_uri, query: query)[:pageEntries]
  if node_sizes.size != 1
    raise "NodeSize with code #{size_code} does not exist."
  end
  node_sizes[0]
end

def find_res_group_for_res_pool(resource_pool_uri)
  pool = UU::OperationRegistry::ResourcePool.get_attributes(resource_pool_uri)
  canonize_uri(pool[:resourceGroupUri])
rescue UU::OS::CMD::CommandError => e
  if e.code == 'UU.OPERATION.REGISTRY/E001-ENTITY_NOT_EXISTS'
    raise "ResourcePool #{resource_pool_uri} does not exist."
  end
  raise
end

def find_free_hosts(cloud_uri, resource_pool_uri, node_size, restricted_host_codes = nil)
  resource_group_curi = find_res_group_for_res_pool(resource_pool_uri)

  query = {
    resourceGroupUri: resource_group_curi,
    state: UU::OperationRegistry::HostState::ACTIVE,
    :"freeCapacity.cpu" => {:"$gte" => node_size[:cpu]},
    :"freeCapacity.mem" => {:"$gte" => node_size[:mem]},
  }
  if restricted_host_codes
    # Find all free hosts in resource group except the one which contains reference container (for HA)
    query[:code] = { "$nin" => restricted_host_codes }
  end
  return UU::OperationRegistry::Cloud.get_host_list(cloud_uri, {query: query.to_json})[:pageEntries]
end


begin
  app_deployment_attrs = UU::OperationRegistry::AppDeployment.get_attributes(app_deployment_uri)
rescue UU::OS::CMD::CommandError => e
  if e.code == 'UU.OPERATION.REGISTRY/E001-ENTITY_NOT_EXISTS'
    raise "AppDeployment #{app_deployment_uri} does not exist."
  else
    raise e
  end
end

unless app_deployment_attrs[:state] == "DEPLOYED"
  raise "AppDeployment #{app_deployment_uri} invalid state. Expected DEPLOYED, but #{app_deployment_attrs[:state]} found."
end

def create_node_and_container_in_or(app_deployment_curi, host, reference_container, reference_node, index, dry_run)
  new_container_name = "#{reference_container[:name]}-dup-#{index}-#{Time.now.to_i}"

  if dry_run
    new_container_name = "dry_run_nothing_really_created"
  else
    new_node = UU::OperationRegistry::Node.create(
      host[:uri],
      hostname: host[:hostname],
      resourcePoolUri: reference_node[:resourcePoolUri],
      nodeSizeUri: reference_node[:nodeSizeUri],
      nodeSetUri: reference_node[:nodeSetUri],
      appDeploymentUri: app_deployment_curi
    )
    new_container =  UU::OperationRegistry::Container.create(
      new_node,
      name: new_container_name,
      nodeImageUri: reference_container[:nodeImageUri],
      nodeSetUri: reference_container[:nodeSetUri],
      appDeploymentUri: app_deployment_curi,
      state: "RUNNING"
    )
  end

  puts "Run the following command on host #{host[:hostname]}:"
  puts "  docker run --name #{new_container_name} hello-world"
  puts
end

def print_hosts_counts(hosts, msg)
  hosts.each do |host|
    puts "Host '#{host[:code]}' #{msg}: #{host[:containerCount]}"
  end
end

app_deployment_curi = canonize_uri(app_deployment_attrs[:uri])
query_string_nodeset = {appDeploymentUri: app_deployment_curi, slot: target_slot}.to_json
current_nodeset = UU::OperationRegistry::Cloud.get_node_set_list(cloud_uri, query: query_string_nodeset)[:pageEntries][0]

if current_nodeset.nil?
  raise "No NodeSet found for AppDeployment #{app_deployment_uri} and slot #{target_slot}."
end

query_string = {appDeploymentUri: app_deployment_curi, state:"RUNNING", nodeSetUri: current_nodeset[:uri]}.to_json

current_containers = UU::OperationRegistry::Cloud.get_container_list(cloud_uri,  query: query_string)[:pageEntries]
reference_container = current_containers[0]
if reference_container.nil?
  raise "No running container found for app deployment #{app_deployment_uri} and slot #{target_slot}."
end
current_container_count = current_containers.size
puts "Currently running containers count for app deployment is #{current_container_count}."

if target_container_count <= current_container_count
  puts <<-WARNING_MSG
  WARNING: Count of currently running containers >= requested target count of containers.

  Doing nothing!

  WARNING_MSG
  exit(0)
end
required_containers_count = target_container_count - current_container_count
puts "Required count of containers to create: #{required_containers_count}"

reference_node = UU::OperationRegistry::Node.get_attributes(reference_container[:nodeUri])
node_size_code = UU::OperationRegistry::NodeSize.get_attributes(reference_node[:nodeSizeUri])[:code]
puts "Required node size: #{node_size_code}"
node_size = get_node_size(cloud_uri, node_size_code)

if require_different_hosts
  restricted_host_codes = []
  current_containers.each do |container|
    restricted_host_codes << UU::OperationRegistry::Host.get_attributes(container[:hostUri])[:code]
  end


  puts ("Finding host suitable for deployment of a new node.")
  hosts = find_free_hosts(cloud_uri, reference_node[:resourcePoolUri], node_size, restricted_host_codes)
  puts "Found #{hosts.size} hosts suitable for running new containers."

  if hosts.size < required_containers_count
    raise "Not enough suitable hosts found for deployment of a new #{node_size_code} nodes."
  else
    puts "Creating new containers in Operation Registry"
    puts
    required_containers_count.times do |index|
      create_node_and_container_in_or(app_deployment_curi, hosts[index], reference_container, reference_node, index, dry_run)
    end
  end
else
  hosts = find_free_hosts(cloud_uri, reference_node[:resourcePoolUri], node_size)
  raise "No free host found for a new #{node_size_code} node." if hosts.empty?

  hosts.each do |host|
    host[:containerCount] = current_containers.count do |container|
      container[:hostUri] == host[:uri]
    end
    host[:containersToAllocate] = 0
  end
  print_hosts_counts(hosts, "currently runs containers")
  free_hosts = hosts.dup

  required_containers_count.times do |index|
    host = free_hosts.min_by { |h| h[:containerCount] }
    host[:containerCount] += 1
    host[:containersToAllocate] += 1
    host[:freeCapacity][:cpu] -= node_size[:cpu]
    host[:freeCapacity][:mem] -= node_size[:mem]
    free_hosts.delete(host) if host[:freeCapacity][:cpu] < node_size[:cpu]
    free_hosts.delete(host) if host[:freeCapacity][:mem] < node_size[:mem]
    if free_hosts.empty?
      puts "There is not enough capacity on free hosts for given container count."
      print_hosts_counts(hosts, "maximum possible running containers")
      raise "Not enough suitable hosts found for deployment of a new #{node_size_code} nodes."
    end
  end

  puts "Creating new containers in Operation Registry"
  puts
  hosts.each do |host|
    host[:containersToAllocate].times do |index|
      create_node_and_container_in_or(app_deployment_curi, host, reference_container, reference_node, index, dry_run)
    end
  end
  print_hosts_counts(hosts, "will run containers")
end


puts "Script finished OK"
