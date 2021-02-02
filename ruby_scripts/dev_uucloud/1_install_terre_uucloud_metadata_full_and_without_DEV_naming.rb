require "uu_operation_registry"
require "uu/os/uesuri"
require "uu/os/uesuri_builder"

################################################################################
### Configuration

# CHANGE THIS - Name of password file for user cast into group configured
#               in OPER_REG_ACCESS_GROUP environment variable for
#               uuCloudg01OperationRegistry app servers
#               see https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-3b9da1e91e854406af308a2f59113fc9/book/page?code=installationAndOperation
CREDENTIALS = "22-7709-1"

# CHANGE THIS - use the same value as in CLOUD_CODE environment variable
#               for uuCloudg01OperationRegistry and uuCloudg01C3 app servers
#               see https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-3b9da1e91e854406af308a2f59113fc9/book/page?code=installationAndOperation
#               and https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-289fcd2e11d34f3e9b2184bedb236ded/book/page?code=installationAndOperation
CLOUD_CODE = "DEMO"

# CHANGE THIS - use the same value as in OPERATION_TERRITORY_CODE environment variable
#               for uuCloudg01OperationRegistry and uuCloudg01C3 app servers
#               see https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-3b9da1e91e854406af308a2f59113fc9/book/page?code=installationAndOperation
#               and https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-289fcd2e11d34f3e9b2184bedb236ded/book/page?code=installationAndOperation
OPER_TER_CODE = "DTC-BT"

# CHANGE THIS - use the same value as in REPO_PREFIX variable in tag/push scripts
#               for uuCloudg01C3 runtime stacks
#               see https://uuos9.plus4u.net/uu-bookkitg01-main/78462435-289fcd2e11d34f3e9b2184bedb236ded/book/page?code=installationAndOperation
DOCKER_REPO_PREFIX = "syshost:5000"

### End of configuration
################################################################################

UU::OS::Security::Session.login(CREDENTIALS)

puts "#" * 90
puts "### Installing uuCloud metadata into uuCloud instance #{CLOUD_CODE}..."
puts "#" * 90

################################################################################
# Helper functions
################################################################################

def uesuri(art_code)
  UU::OS::UESURI.create(
    territory_code: OPER_TER_CODE,
    artifact_code: art_code
  ).to_s
end

CLOUD_URI = uesuri(CLOUD_CODE)

def fake_app_deploy_uri(pool_uri, app_code)
  UU::OS::UESURIBuilder.parse_uesuri(pool_uri).set_object_id(app_code).to_uesuri
end

################################################################################
# Regions
################################################################################

puts "\n[1/9] Creating regions..."

region_demo_uri = UU::OperationRegistry::Region.create(
  CLOUD_URI,
  name: "Azure West Europe 1",
  code: "eu-we-1",
  resources: {
    graylogSearchUrl: "http://reader:reader@graylog:9000/api",
    graylogStreamId: "5be470b1e6cac1000169a773"
  }
)
#all_regions = UU::OperationRegistry::Region.get_region_list(CLOUD_URI,query:'{"code":"eu-fc-dev"}')#"code":"DTC-BT"
#region_demo_uri=all_regions[:pageEntries][0][:uri]
puts "Region URI: #{region_demo_uri}"

###############################################################################
# ResourceGroups
###############################################################################

puts "\n[2/9] Creating resource groups..."

rg_gw_uri = UU::OperationRegistry::ResourceGroup.create(
    region_demo_uri,
    name: "gws",
    code: "gws",
    description: "DEMO - GATEWAYS"
)

#all_resource_groups = UU::OperationRegistry::RuntimeStack.get_runtime_stack_list(CLOUD_URI, query:'{"code": "--gws"}')
#rg_gw_uri=all_resource_groups[:pageEntries][0][:uri]
puts "Resource group gws URI: #{rg_gw_uri}"

rg_swarm_uri = UU::OperationRegistry::ResourceGroup.create(
  region_demo_uri,
  name: "swarm",
  code: "swarm",
  description: "DEMO - SWARM",
  nodeProvider: "SWARM",
  nodeProviderParameters: {
    url : "http://swarmmanager:4243" },
  contractedCapacity: {
      "cpu" : 24,
      "mem" : 24000,
      "storage" : 12000
  },
  freeCapacity: {
      "cpu" : 24,
      "mem" : 24000,
      "storage" : 12000
  }
)
puts "Resource group swarm URI: #{rg_swarm_uri}"

rg_plain_uri = UU::OperationRegistry::ResourceGroup.create(
  region_demo_uri,
  name: "plaindocker",
  code: "plaindocker",
  description: "DEMO - PLAIN DOCKER"
)
puts "Resource group plain docker URI: #{rg_plain_uri}"

rg_logstorecmd_uri = UU::OperationRegistry::ResourceGroup.create(
  region_demo_uri,
  name: "logstorecmd",
  code: "logstorecmd",
  description: "DEMO - LOGSTORE CMD"
)
puts "Resource group logstore cmd URI: #{rg_logstorecmd_uri}"

################################################################################
# Hosts
################################################################################

puts "#" * 90
puts "\n[3/9] Creating hosts..."

host_gw_01_uri = UU::OperationRegistry::Host.create(
    rg_gw_uri,
    name: "gw",
    code: "gw",
    hostname: "gw",
    totalCapacity: {
        cpu: 4,
        mem: 4_000,
        storage: 2_000
    }
)
UU::OperationRegistry::Host.set_attributes(host_gw_01_uri, state: "ACTIVE")
puts "- #{host_gw_01_uri}"

host_syshost_uri = UU::OperationRegistry::Host.create(
  rg_logstorecmd_uri,
  name: "syshost",
  code: "syshost",
  hostname: "syshost",
  totalCapacity: {
    cpu: 1,
    mem: 1_000,
    storage: 1_000
  },
  reinitStrategy: "SUPPORTED",
)
UU::OperationRegistry::Host.set_attributes(host_syshost_uri, state: "ACTIVE")
puts "- #{host_syshost_uri}"

host_docker1_uri = UU::OperationRegistry::Host.create(
    rg_swarm_uri,
    name: "dockerhost1",
    code: "dockerhost1",
    hostname: "dockerhost1",
    totalCapacity: {
        cpu: 11,
        mem: 11_000,
        storage: 9_000
    },
    reinitStrategy: "SUPPORTED"
)
UU::OperationRegistry::Host.set_attributes(host_docker1_uri, state: "ACTIVE")
puts "- #{host_docker1_uri}"

host_docker2_uri = UU::OperationRegistry::Host.create(
    rg_swarm_uri,
    name: "dockerhost2",
    code: "dockerhost2",
    hostname: "dockerhost2",
    totalCapacity: {
        cpu: 11,
        mem: 11_000,
        storage: 9_000
    },
    reinitStrategy: "SUPPORTED"
)
UU::OperationRegistry::Host.set_attributes(host_docker2_uri, state: "ACTIVE")
puts "- #{host_docker2_uri}"

host_docker3_uri = UU::OperationRegistry::Host.create(
    rg_plain_uri,
    name: "dockerhost3",
    code: "dockerhost3",
    hostname: "dockerhost3",
    totalCapacity: {
        cpu: 11,
        mem: 11_000,
        storage: 9_000
    },
    reinitStrategy: "SUPPORTED"
)
UU::OperationRegistry::Host.set_attributes(host_docker3_uri, state: "ACTIVE")
puts "- #{host_docker3_uri}"

host_docker4_uri = UU::OperationRegistry::Host.create(
    rg_plain_uri,
    name: "dockerhost4",
    code: "dockerhost4",
    hostname: "dockerhost4",
    totalCapacity: {
        cpu: 11,
        mem: 11_000,
        storage: 9_000
    },
    reinitStrategy: "SUPPORTED"
)
UU::OperationRegistry::Host.set_attributes(host_docker4_uri, state: "ACTIVE")
puts "- #{host_docker4_uri}"

################################################################################
# RuntimeStacks
################################################################################

puts "#" * 90
puts "\n[4/9] Creating runtime stacks..."

stack_image_uuos9_java_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "uu_appg01_java_openjdk_stack:1.6",
  code: "UU.APPG01/JAVA_OPENJDK_STACK-1.6",
  imageUrl: "#{DOCKER_REPO_PREFIX}/uu_appg01_java_openjdk_stack:1.6",
  inboundPorts: [
    8080
  ]
)
puts "- #{stack_image_uuos9_java_uri}"

stack_demo_java_uri = UU::OperationRegistry::RuntimeStack.create(
  CLOUD_URI,
  code: "UU.APPG01/DEMO_JAVA_OPENJDK_STACK-1.6",
  description: "uuAppg01Server use cases (Java 32bit)",
  alias: "DEMO",
  nodeImageUri: stack_image_uuos9_java_uri,
  version: "2.0"
)
puts "- #{stack_demo_java_uri}"

stack_image_uuos9_java64_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "uu_appg01_java_x64_openjdk_stack:1.6",
  code: "UU.APPG01/JAVA_X64_OPENJDK_STACK-1.6",
  imageUrl: "#{DOCKER_REPO_PREFIX}/uu_appg01_java_x64_openjdk_stack:1.6",
  inboundPorts: [
    8080
  ]
)
puts "- #{stack_image_uuos9_java64_uri}"

stack_demo_java64_uri = UU::OperationRegistry::RuntimeStack.create(
  CLOUD_URI,
  code: "UU.APPG01/DEMO_JAVA_X64_OPENJDK_STACK-1.6",
  description: "uuAppg01Server use cases (Java 64bit)",
  alias: "DEMO",
  nodeImageUri: stack_image_uuos9_java64_uri,
  version: "2.0"
)
puts "- #{stack_demo_java64_uri}"

stack_image_uuos9_nodejs_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "uu_os9_uc_nodejs_stack:1.6",
  code: "UU.APPG01/DEMO_NODEJS_STACK-1.6",
  imageUrl: "#{DOCKER_REPO_PREFIX}/uu_os9_uc_nodejs_stack:1.6",
  inboundPorts: [
    8080
  ]
)
puts "- #{stack_image_uuos9_nodejs_uri}"

stack_demo_nodejs_uri = UU::OperationRegistry::RuntimeStack.create(
  CLOUD_URI,
  code: "UU.APPG01/DEMO_NODEJS_STACK-1.6",
  description: "uuAppg01Server use cases (Node.js)",
  alias: "DEMO",
  nodeImageUri: stack_image_uuos9_nodejs_uri,
  version: "2.0"
)
puts "- #{stack_demo_nodejs_uri}"

stack_image_uuos8_jruby_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "uu_os_cmd_jruby_stack:1.1",
  code: "CMD_JRUBY_V1.1",
  imageUrl: "#{DOCKER_REPO_PREFIX}/uu_os_cmd_jruby_stack:1.1",
  inboundPorts: [
    8080
  ]
)
puts "- #{stack_image_uuos8_jruby_uri}"

stack_demo_jruby_uri = UU::OperationRegistry::RuntimeStack.create(
  CLOUD_URI,
  code: "CMD_JRUBY_V1.1",
  description: "uuApps 2.1 commands (JRuby 1.7)",
  alias: "DEMO",
  nodeImageUri: stack_image_uuos8_jruby_uri,
  version: "1.0"
)
puts "- #{stack_demo_jruby_uri}"

################################################################################
# NodeSizes
################################################################################

puts "\n[5/9] Creating node sizes..."

node_size_c01m01s01_uri = UU::OperationRegistry::NodeSize.create(
  CLOUD_URI,
  code: "C01M01S01",
  cpu: 1,
  mem: 1_000,
  storage: 1_000
)
puts "- #{node_size_c01m01s01_uri}"

node_size_c02m02s01_uri = UU::OperationRegistry::NodeSize.create(
 CLOUD_URI,
 code: "C02M02S01",
 cpu: 2,
 mem: 2_000,
 storage: 1_000
)
puts "- #{node_size_c02m02s01_uri}"

node_size_c04m08s01_uri = UU::OperationRegistry::NodeSize.create(
 CLOUD_URI,
 code: "C04M08S01",
 cpu: 4,
 mem: 8_000,
 storage: 1_000
)
puts "- #{node_size_c04m08s01_uri}"

################################################################################
# Tenants
################################################################################

puts "\n[6/9] Getting tenant..."

#get tenant by code  - only operation tenant should be selected
all_tenants = UU::OperationRegistry::Tenant.get_tenant_list(CLOUD_URI,query:'{"code":"DTC-BT"}')
#get first tenant from list
tenant_demo_bt_uri=all_tenants[:pageEntries][0][:uri]
puts "- #{tenant_demo_bt_uri}"

################################################################################
# ResourcePools
################################################################################

puts "#" * 90
puts "\n[7/9] Creating resource pools..."

###########################################
puts "Swarm"
pool_demo_bt_common_uri = UU::OperationRegistry::ResourcePool.create(
    tenant_demo_bt_uri,
    name: "SWARM",
    code: "SWARM",
    accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
    auditorsUri: "ues:UNI-BT:USYE.LIBRAD~TEAM",
    contractedCapacity: {
        cpu: 22,
        mem: 22_000,
        storage: 18_000
    },
    resourceGroupUri: rg_swarm_uri
)
puts "- #{pool_demo_bt_common_uri}"

###########################################
puts "Plain Docker"
pool_demo_bt_dm_uri = UU::OperationRegistry::ResourcePool.create(
  tenant_demo_bt_uri,
  name: "PLAIN",
  code: "PLAIN",
  accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
  auditorsUri: "ues:UNI-BT:USYE.LIBRAD~TEAM",
  contractedCapacity: {
    cpu: 16,
    mem: 32_000,
    storage: 4_000
  },
  resourceGroupUri: rg_plain_uri
)
puts "- #{pool_demo_bt_dm_uri}"

###########################################
puts "DEV Gateways"
pool_demo_bt_gw_uri = UU::OperationRegistry::ResourcePool.create(
  tenant_demo_bt_uri,
  name: "GWS",
  code: "DEMO_GW",
  accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
  auditorsUri: "ues:UNI-BT:USYE.LIBRAD~TEAM",
  contractedCapacity: {
    cpu: 8,
    mem: 8_000,
    storage: 4_000
  },
  resourceGroupUri: rg_gw_uri
)
puts "- #{pool_demo_bt_gw_uri}"

pool_logstorecmd_uri = UU::OperationRegistry::ResourcePool.create(
  tenant_demo_bt_uri,
  name: "LOGSTORE CMD",
  code: "DEMO_LOGSTORECMD",
  accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
  auditorsUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
  contractedCapacity: {
    cpu: 1,
    mem: 1_000,
    storage: 1_000
  },
  resourceGroupUri: rg_logstorecmd_uri
)
puts "- #{pool_logstorecmd_uri}"

################################################################################
# Gateways
################################################################################

puts "\n[9/9] Creating gateways..."

# gateway
puts "* gateway..."

app_deployment_demo_gw_uri = fake_app_deploy_uri(pool_demo_bt_gw_uri, "DEMO_GW")

stack_image_demo_gw_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "demo_gateway_base:1.0",
  code: "GW_DEMO_DEV_V1.0_BASE_IMAGE",
  imageUrl: "#{DOCKER_REPO_PREFIX}/demo_gateway_base:1.0",
  inboundPorts: [
    80 # defined in Dockerfile
  ]
)
puts "  - NodeImage #{stack_image_demo_gw_uri}"

stack_demo_gw_uri = UU::OperationRegistry::RuntimeStack.create(
  CLOUD_URI,
  code: "GATEWAY_DEMO_V1.0",
  alias: "GATEWAY_DEMO",
  nodeImageUri: stack_image_demo_gw_uri
)
puts "  - RuntimeStack #{stack_demo_gw_uri}"

node_image_demo_gw_uri = UU::OperationRegistry::NodeImage.create(
  CLOUD_URI,
  name: "uu_gateway_demo:1.0",
  code: "GW_DEMO_V1.0_IMAGE",
  inboundPorts: [
    80 # defined in Dockerfile
  ],
  runtimeStackUri: stack_demo_gw_uri
)
puts "  - NodeImage #{node_image_demo_gw_uri}"

prod_node_set_demo_gw_uri = UU::OperationRegistry::NodeSet.create(
  pool_demo_bt_gw_uri,
  name: "Gateway Nodes",
  code: "DEMO_GW",
  slot: "PRODUCTION",
  appDeploymentUri: app_deployment_demo_gw_uri,
  urlPath: "/",
)
puts "  - NodeSet #{prod_node_set_demo_gw_uri}"

beta_node_set_demo_gw_uri = UU::OperationRegistry::NodeSet.create(
    pool_demo_bt_gw_uri,
    name: "BETA Gateway Nodes",
    code: "BETA/DEMO_GW",
    slot: "BETA",
    appDeploymentUri: app_deployment_demo_gw_uri,
    urlPath: "/",
    )
puts "  - NodeSet #{beta_node_set_demo_gw_uri}"

prod_node_demo_gw_01_uri = UU::OperationRegistry::Node.create(
  host_gw_01_uri,
  code: "PRODUCTION_DEMO_GW_0001",
  appDeploymentUri: app_deployment_demo_gw_uri,
  hostname: "syshost",
  nodeSetUri: prod_node_set_demo_gw_uri,
  nodeSizeUri: uesuri("C02M02S01"),
  resourcePoolUri: pool_demo_bt_gw_uri
)
puts "  - Node #{prod_node_demo_gw_01_uri}"

beta_node_demo_gw_01_uri = UU::OperationRegistry::Node.create(
    host_gw_01_uri,
    code: "BETA_DEMO_GW_0001",
    appDeploymentUri: app_deployment_demo_gw_uri,
    hostname: "syshost",
    nodeSetUri: beta_node_set_demo_gw_uri,
    nodeSizeUri: uesuri("C02M02S01"),
    resourcePoolUri: pool_demo_bt_gw_uri
)
puts "  - Node #{beta_node_demo_gw_01_uri}"

container_demo_gw_01_uri = UU::OperationRegistry::Container.create(
  prod_node_demo_gw_01_uri,
  name: "uuos9_gateway_base",
  appDeploymentUri: app_deployment_demo_gw_uri,
  inboundPorts: [
    80 # published port
  ],
  nodeImageUri: node_image_demo_gw_uri,
  nodeSetUri: prod_node_set_demo_gw_uri,
  state: "RUNNING"
)
puts "  - Container #{container_demo_gw_01_uri}"

beta_container_demo_gw_01_uri = UU::OperationRegistry::Container.create(
    beta_node_demo_gw_01_uri,
    name: "uuos9_gateway_base",
    appDeploymentUri: app_deployment_demo_gw_uri,
    inboundPorts: [
        81 # published port
    ],
    nodeImageUri: node_image_demo_gw_uri,
    nodeSetUri: beta_node_set_demo_gw_uri,
    state: "RUNNING"
)
puts "  - Container #{beta_container_demo_gw_01_uri}"

puts "\n"
puts "*** Done :) ***"

