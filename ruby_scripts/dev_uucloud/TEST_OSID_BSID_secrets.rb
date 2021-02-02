require "uu_operation_registry"

CREDENTIALS = "22-7709-1"

CLOUD_URI = "ues:DTC-BT:DEMO"

UU::OS::Security::Session.login(CREDENTIALS)


secret = UU::OperationRegistry::Secret.create(CLOUD_URI, name: 'test-osid-dtc',code: '7b0e1777251143e08ce1f3c27c933d04', value: 'mongodb://syshost:27017/test-osid')
resource_lease = UU::OperationRegistry::ResourceLease.create(CLOUD_URI,
                                                             resourceType: "DATA_STORE",
                                                             constraints: {
                                                                 vendor: "DTC"
                                                             },
                                                             resourceUri:secret
)
