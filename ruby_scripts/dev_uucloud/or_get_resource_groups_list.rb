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

all_regions = UU::OperationRegistry::Region.get_region_list(CLOUD_URI)

region_terre_uri=all_regions[:pageEntries][0][:uri]
puts "region terre uri - #{region_terre_uri}"

future = UU::OperationRegistry::ResourceGroup.get_resource_group_list(region_terre_uri)
puts(JSON.pretty_generate(future))

