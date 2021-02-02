require "uu_os"
require "uu_c3"
require_relative 'waiter'
include Waiter

# rake -f dev_deploy_echo_appbox.rake deployEchoOnECPAppbox[1.0.0,DEV,PRODUCTION,blue]
# rake -f dev_deploy_echo_appbox.rake deployEchoOnECPAppbox[1.0.0,DEV,BETA,green]
# rake -f dev_deploy_echo_appbox.rake deployEchoOnLOMAppbox[1.0.0,DEV,PRODUCTION,blue]
# rake -f dev_deploy_echo_appbox.rake deployEchoOnLOMAppbox[1.0.0,DEV,BETA,green]

task :deployEchoOnECPAppbox, :appBoxVersion, :environment, :targetSlot, :targetSlotConfiguration do |t, args|
  UU::OS::Security::Session.login("22-7709-1")
  future = UU::C3::AppDeployment.deploy("ues:DTC-BT:SWARM",
                                        appBoxUri: "ues:DTC-BT:DTC.TERRE/ECHO", targetSlot: args[:targetSlot],
                                        config: {
                                            "APP_BOX_VERSION" => "#{args[:appBoxVersion]}",
                                            "ENVIRONMENT" => "#{args[:environment].upcase}",
                                            "TARGET_SLOT" => "#{args[:targetSlot]}",
                                            "TARGET_SLOT_CONFIGURATION" => "#{args[:targetSlotConfiguration]}"
                                        })
  Waiter.wait_for_finish_with_future(future)
end

task :deployEchoOnLOMAppbox, :appBoxVersion, :environment, :targetSlot, :targetSlotConfiguration do |t, args|
  UU::OS::Security::Session.login("22-7709-1")
  future = UU::C3::AppDeployment.deploy("ues:DTC-BT:PLAIN",
                                        appBoxUri: "ues:DTC-BT:DTC.TERRE/ECHO2", targetSlot: args[:targetSlot],
                                        config: {
                                            "APP_BOX_VERSION" => "#{args[:appBoxVersion]}",
                                            "ENVIRONMENT" => "#{args[:environment].upcase}",
                                            "TARGET_SLOT" => "#{args[:targetSlot]}",
                                            "TARGET_SLOT_CONFIGURATION" => "#{args[:targetSlotConfiguration]}"
                                        })
  Waiter.wait_for_finish_with_future(future)
end
