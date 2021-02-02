# rake -f deploy_uu_logstore.rake deployment
require_relative 'waiter'
include Waiter

task :deployment do |t|
  require 'uu_os'
  require 'uu_c3'
  UU::OS::Security::Session.login("22-7709-1")
  future = UU::C3::AppDeployment.deploy("ues:DTC-BT:DEMO_LOGSTORECMD",
                                        appBoxUri: "ues:DTC-BT:UU-LOGSTOREG01/APPBOX-1.8.2",
                                        config: {
                                            graylogSearchUrl: "http://reader:reader@graylog:9000/api",
                                            graylogStreamId: "5be470b1e6cac1000169a773",
                                            accessGroupUri: "ues:DTC-BT:DTC.TERRE~DEPLOYERS"
                                        },
                                        uuEEs: ["22-7709-1"]
  )
  puts(future)
  Waiter.wait_for_finish_with_future(future)
end