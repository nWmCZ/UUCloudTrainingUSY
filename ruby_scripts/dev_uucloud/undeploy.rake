require "uu_os"
require "uu_c3"
require_relative 'waiter'
include Waiter

UU::OS::Security::Session.login("22-7709-1")

# rake -f undeploy.rake undeploy[ues:DTC-BT[99923616732520257]:SWARM[600ac927f76e02143f2152a3]:DTC.ECHO[600f342f1aba15297526b33d],BETA,false]

task :undeploy, :appDeploymentUri, :targetSlot, :useForce do |t, args|
  future = UU::C3::AppDeployment.undeploy(args[:appDeploymentUri], targetSlot: args[:targetSlot], force: args[:useForce])
  Waiter.wait_for_finish_with_future(future)
end
