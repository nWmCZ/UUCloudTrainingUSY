require 'uu_os'
require 'uu_operation_registry'
require 'json'

CLOUD_CODE = "DEMO"

OPER_TER_CODE = "DTC-BT"

def uesuri(art_code)
  UU::OS::UESURI.create(
      territory_code: OPER_TER_CODE,
      artifact_code: art_code
  ).to_s
end

CLOUD_URI = uesuri(CLOUD_CODE)

UU::OS::Security::Session.login("22-7709-1")

all_tenants = UU::OperationRegistry::Tenant.get_tenant_list(CLOUD_URI)
tenant=all_tenants[:pageEntries][0][:uri]
puts "tenant uri - #{tenant}"

puts(tenant)


all_rp = UU::OperationRegistry::ResourcePool.get_resource_pool_list(tenant)
puts(JSON.pretty_generate(all_rp))
