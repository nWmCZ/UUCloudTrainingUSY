require "uu_operation_registry"

CREDENTIALS = "22-7709-1"

CLOUD_URI = "ues:DTC-BT:DEMO"

UU::OS::Security::Session.login(CREDENTIALS)


secret = UU::OperationRegistry::Secret.create(CLOUD_URI, name: 'uujokes-osid',code: 'uujokes-osid', value: 'mongodb://syshost:27017/uujokes-osid')
resource_lease = UU::OperationRegistry::ResourceLease.create(CLOUD_URI,
                                                             resourceType: "DATA_STORE",
                                                             constraints: {
                                                                 vendor: "UU"
                                                             },
                                                             resourceUri:secret
)

secret = UU::OperationRegistry::Secret.create(CLOUD_URI, name: 'uujokes-bsid',code: 'uujokes-bsid', value: 'mongodb://syshost:27017/uujokes-bsid')
resource_lease = UU::OperationRegistry::ResourceLease.create(CLOUD_URI,
                                                             resourceType: "DATA_STORE",
                                                             constraints: {
                                                                 vendor: "UU"
                                                             },
                                                             resourceUri:secret
)
