# require 'uu_os'
require 'uu_c3'
require 'json'
UU::OS::Security::Session.login("22-7709-1")
future = UU::C3::AppDeployment.get_app_deployment_list("ues:DTC-BT:SWARM")
puts(JSON.pretty_generate(future))

