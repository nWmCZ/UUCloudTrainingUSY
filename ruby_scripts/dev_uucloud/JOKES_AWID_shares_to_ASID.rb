require "uu_operation_registry"
require "uu_c3"

# Log in as user cast into group configured in OPER_REG_ACCESS_GROUP
UU::OS::Security::Session.login("22-7709-1")

CLOUD_URI = UU::OS::UESURI.new("ues:DTC-BT:DEMO")

asid = '11111111111111111111111111111111'
app_deployment_uri=UU::OperationRegistry::Cloud.get_app_deployment_list(CLOUD_URI, query: {state: "DEPLOYED", asid: "#{asid}"}.to_json)[:pageEntries][0][:uri]
awid = '22222222222222222222222222222222'
UU::C3::AppDeployment.share(app_deployment_uri, territories: ["ues:99923616732520257-#{awid}:99923616732520257-#{awid}"])
