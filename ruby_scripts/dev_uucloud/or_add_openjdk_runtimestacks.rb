require 'uu_os'
require 'uu_operation_registry'
require 'json'

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
DOCKER_REPO_PREFIX = "registry:5000"

ENVIRONMENT = "DEMO"

RUNTIMESTACK_VERSION = "1.4.1"

### End of configuration
################################################################################

UU::OS::Security::Session.login(CREDENTIALS)

puts "#" * 90
puts "### Installing uuCloud metadata for TERRE into uuCloud instance #{CLOUD_CODE}..."
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

puts "\nCreating runtime stacks..."

stack_image_uuos9_java_uri = UU::OperationRegistry::NodeImage.create(
    CLOUD_URI,
    name: "uu_appg01_java_openjdk_stack:#{RUNTIMESTACK_VERSION}",
    code: "UU.APPG01/JAVA_OPENJDK_STACK-#{RUNTIMESTACK_VERSION}",
    imageUrl: "#{DOCKER_REPO_PREFIX}/uu_appg01_java_openjdk_stack:#{RUNTIMESTACK_VERSION}",
    inboundPorts: [
        8080
    ]
)
puts "- #{stack_image_uuos9_java_uri}"

stack_libra_java_uri = UU::OperationRegistry::RuntimeStack.create(
    CLOUD_URI,
    code: "UU.APPG01/#{ENVIRONMENT}_JAVA_OPENJDK_STACK-#{RUNTIMESTACK_VERSION}",
    description: "uuAppg01Server use cases (Java 32bit)",
    alias: "DEMO",
    nodeImageUri: stack_image_uuos9_java_uri,
    version: "2.0"
)
puts "- #{stack_libra_java_uri}"

stack_image_uuos9_java64_uri = UU::OperationRegistry::NodeImage.create(
    CLOUD_URI,
    name: "uu_appg01_java_x64_openjdk_stack:#{RUNTIMESTACK_VERSION}",
    code: "UU.APPG01/JAVA_X64_OPENJDK_STACK-#{RUNTIMESTACK_VERSION}",
    imageUrl: "#{DOCKER_REPO_PREFIX}/uu_appg01_java_x64_openjdk_stack:#{RUNTIMESTACK_VERSION}",
    inboundPorts: [
        8080
    ]
)
puts "- #{stack_image_uuos9_java64_uri}"

stack_libra_java64_uri = UU::OperationRegistry::RuntimeStack.create(
    CLOUD_URI,
    code: "UU.APPG01/#{ENVIRONMENT}_JAVA_X64_OPENJDK_STACK-#{RUNTIMESTACK_VERSION}",
    description: "uuAppg01Server use cases (Java 64bit)",
    alias: "DEMO",
    nodeImageUri: stack_image_uuos9_java64_uri,
    version: "2.0"
)
puts "- #{stack_libra_java64_uri}"
