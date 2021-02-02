require "uu_c3"
app_deployment_uri = "ues:DTC-BT[99923616732520257]:SWARM[600ac927f76e02143f2152a3]:DTC.ECHO[600f342f1aba15297526b33d]"
node_count = 1

UU::OS::Security::Session.login("22-7709-1")

app_deployment = UU::C3::AppDeployment.new(UU::OS::Security::Session.current_session)
app_deployment.scale(app_deployment_uri, nodeCount: node_count)
