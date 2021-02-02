require "uu_operation_registry"

# Log in as user cast into group configured in OPER_REG_ACCESS_GROUP
UU::OS::Security::Session.login("22-7709-1")

############################################# CHANGE THIS ##############################################################

CLOUD_URI = "ues:DTC-BT:DEMO"
REPO_PREFIX = "registry:5000"

########################################################################################################################

################################################################################
# Base images
################################################################################
attributes = {
    name: "uu_os9_uc_ruby_stack:1.0",
    inboundPorts: [8080],
    imageUrl: "#{REPO_PREFIX}/uu_os9_uc_ruby_stack:1.0"
}
node_image = UU::OperationRegistry::NodeImage.get_node_image_list(CLOUD_URI, criteria = {query: {name: attributes[:name]}.to_json})
unless node_image[:totalSize] > 0
  node_image = UU::OperationRegistry::NodeImage.create(CLOUD_URI, attributes)
  puts "- Created NodeImage #{node_image}"
else
  node_image = node_image[:pageEntries].first[:uri]
  puts "- NodeImage exists #{node_image} skipping..."
end
################################################################################
# RuntimeStacks
################################################################################
attributes = {
    code: "UU.APPG01/DEMO_UC_RUBY_STACK-1.0",
    alias: "DEMO",
    version: "2.0",
    nodeImageUri: node_image,
    scalable: true
}
runtime_stack = UU::OperationRegistry::RuntimeStack.get_runtime_stack_list(CLOUD_URI, criteria = {query: {code: attributes[:code]}.to_json})

unless runtime_stack[:totalSize] > 0
  runtime_stack = UU::OperationRegistry::RuntimeStack.create(CLOUD_URI, attributes)
  puts "- Created RuntimeStack #{runtime_stack}"
else
  runtime_stack = runtime_stack[:pageEntries].first[:uri]
  puts "- RuntimeStack exists #{runtime_stack} skipping..."
end
