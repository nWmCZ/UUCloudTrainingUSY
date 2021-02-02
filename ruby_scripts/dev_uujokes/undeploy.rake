require "uu_os"
require "uu_c3"
require_relative 'waiter'
include Waiter

UU::OS::Security::Session.login("22-7709-1")

# rake -f undeploy.rake undeploy[ues:[99923616732520257]:[5f805009e2fb71c3fcb98764]:[5f9c1a5312a98bc9aef9dd48],PRODUCTION,false]

task :undeploy, :appDeploymentUri, :targetSlot, :useForce do |t, args|
  future = UU::C3::AppDeployment.undeploy(args[:appDeploymentUri], targetSlot: args[:targetSlot], force: args[:useForce])
  Waiter.wait_for_finish_with_future(future)
end
