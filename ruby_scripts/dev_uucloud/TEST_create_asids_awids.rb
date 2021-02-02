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
APP_NAME = 'UU.TEST'

require "uu_operation_registry"

UU::OS::Security::Session.login(CREDENTIALS) # change appropriately

tenant = UU::OperationRegistry::Tenant.get_attributes(TENANT_URI)
tenants_attrs = []


asid='deaa388dfb55404394db67a9bea5eed1'
name = APP_NAME.nil? ? asid : APP_NAME
tenants_attrs << {code: "#{tenant[:oid]}-#{asid}", name: "#{tenant[:code]} #{name} AppServer", type: "ASID", tid: "99923616732520257", oid:"#{tenant[:oid]}#{asid}"}

awid='51c9e167007a463db9e17b8c7c8a905f'
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


