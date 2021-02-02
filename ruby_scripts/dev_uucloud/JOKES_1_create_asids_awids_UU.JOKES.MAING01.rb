#
# Registers ASIDs (AppServer identifiers) and/or AWIDs (AppWorkspace identifiers)
#

# CHANGE THIS - use credentials of someone authorized to access and modify data in uuOperation Registry
CREDENTIALS = '22-7709-1'

# CHANGE THIS - use UESURI of uuCloud
CLOUD_URI = "ues:DTC-BT:DEMO"

# CHANGE THIS - use UESURI of tenant that you want to create ASIDs and/or AWIDs for
TENANT_URI = "ues:DTC-BT:DTC-BT"

# CHANGE THIS - specify uuApp name which the ASIDs/AWIDs belong to (used in tenant name)
APP_NAME = 'UU.JOKES.MAING01'

require "uu_operation_registry"

UU::OS::Security::Session.login(CREDENTIALS) # change appropriately

tenant = UU::OperationRegistry::Tenant.get_attributes(TENANT_URI)
tenants_attrs = []

asid='98eea23d9697438495eb7be93ff09dff'
name = APP_NAME.nil? ? asid : APP_NAME
tenants_attrs << {code: "#{tenant[:oid]}-#{asid}", name: "#{tenant[:code]} #{name} AppServer", type: "ASID", tid: "99923616732520257", oid:"#{tenant[:oid]}#{asid}"}

awid='292102adaf2f4647a1dea781b5c05310'
name = APP_NAME.nil? ? awid : APP_NAME
tenants_attrs << {code: "#{tenant[:oid]}-#{awid}", name: "#{tenant[:code]} #{name} AppWorkspace", type: "AWID", tid: "99923616732520257", oid:"#{tenant[:oid]}#{awid}"}

tenants_attrs.each do |attrs|
  puts "Creating tenant: #{attrs}"
  attempts = 0
  begin
    attempts += 1
    tenant_uri = UU::OperationRegistry::Tenant.create(CLOUD_URI, attrs)
    puts "=> #{tenant_uri}"
  rescue HTTPClient::ConnectTimeoutError
    if attempts <= 5
      retry
    else
      raise e
    end
  end
end
