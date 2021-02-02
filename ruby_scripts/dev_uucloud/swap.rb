require 'uu_os'
require 'uu_c3'
require_relative 'waiter'

include Waiter

UU::OS::Security::Session.login("22-7709-1")
future = UU::C3::AppDeployment.swap(ARGV[0])
Waiter.wait_for_finish_with_future(future)
