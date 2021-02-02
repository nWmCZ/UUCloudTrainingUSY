require 'time'

module Waiter

  def wait_for_finish_with_future(future)
    puts(future)
    count = 0
    begin
      attrs = future.get
    rescue Timeout::Error => e
      count += 1
      puts(e)
      puts("retry no. #{count}")
      retry
    end
    puts("AppDeployment: #{attrs}")
  end

  def wait_for_finish(app_deployment_uri)
    # wait until the app gets deployed or the deployment fails
    puts("AppDeployment uri: #{app_deployment_uri}")
    loop do
      begin
        attrs = UU::C3::AppDeployment.get_attributes(app_deployment_uri)
      rescue HTTPClient::ConnectTimeoutError => e
        retry
      end
      puts("AppDeployment: #{attrs[:code]}, state: #{attrs[:state]}")
      break if %w(DEPLOYED CREATED UNDEPLOYED).include?(attrs[:state])
      sleep(10)
    end

    attrs = UU::C3::AppDeployment.get_attributes(app_deployment_uri)
    if attrs[:state] == "DEPLOYED"
      puts "Deployment finished successfully"
    else
      puts "Deployment failed"
    end
  end

end
