require "uu_os"
require "uu_c3"
require_relative 'waiter'
include Waiter

# rake -f dev_deploy_uujokes_appbox.rake deployUuJokesAppboxOnECP[2.3.0,DEV,PRODUCTION,blue]
# rake -f dev_deploy_uujokes_appbox.rake deployUuJokesAppboxOnECP[2.1.0-RS1.3,DEV,BETA,green]

task :deployUuJokesAppboxOnECP, :appBoxVersion, :environment, :targetSlot, :targetSlotConfiguration do |t, args|
  UU::OS::Security::Session.login("22-7709-1")
  future = UU::C3::AppDeployment.deploy("ues:DTC-BT:LIBRA_ECP4",
                                        appBoxUri: "ues:DTC-BT:UU.JOKES.MAING01/APPBOX-#{args[:appBoxVersion]}", targetSlot: args[:targetSlot],
                                        config: {
                                            "tid" => "99923616732520257",
                                            "asid" => "11111111111111111111111111111111",
                                            "asidOwner" => "12-3187-1",
                                            "uuSubAppDataStoreMap" => {
                                                "primary" => "osid:uujokes-osid",
                                                "binary" => "bsid:uujokes-bsid"
                                            },
                                            "asid_license_owner_list" => ["12-3187-1"],
                                            "APP_BOX_VERSION" => "#{args[:appBoxVersion]}",
                                            "ENVIRONMENT" => "#{args[:environment].upcase}",
                                            "TARGET_SLOT" => "#{args[:targetSlot]}",
                                            "TARGET_SLOT_CONFIGURATION" => "#{args[:targetSlotConfiguration]}"
                                        })
  Waiter.wait_for_finish_with_future(future)
end
