require "uu_operation_registry"
require "uu/os/uesuri"
require "uu/os/uesuri_builder"
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

UU::OS::Security::Session.login(CREDENTIALS)


# cloud = UU::OperationRegistry::Cloud.get_attributes("ues:DTC-BT:DEMO")
#
# puts(JSON.pretty_generate(cloud))
#
# region = UU::OperationRegistry::Region.get_attributes("ues:DTC-BT:eu-fc-1")
#
# puts(JSON.pretty_generate(region))

# rg_test = UU::OperationRegistry::ResourceGroup.create(
#     "ues:DTC-BT:eu-fc-1",
#     name: "test2",
#     code: "test2",
#     description: "test2"
# )

# rp_test = UU::OperationRegistry::ResourcePool.create(
# #     "ues:DTC-BT:DTC-BT",
# #     name: "test",
# #     code: "test",
# #     description: "test",
# #     accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS",
# #     contractedCapacity: {
# #         cpu: 16,
# #         mem: 32_000,
# #         storage: 4_000
# #     },
# #     resourceGroupUri: "ues:DTC-BT[99923616732520257]:test[601003c61aba151bca7a025e]"
# # )
#
host_gw_01_uri = UU::OperationRegistry::Host.create(
    "ues:DTC-BT[99923616732520257]:test[601003c61aba151bca7a025e]",
    name: "testhost",
    code: "testhost",
    hostname: "testhost",
    totalCapacity: {
        cpu: 44,
        mem: 44_000,
        storage: 22_000
    }
)