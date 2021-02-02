# uuCloud training
Disclaimer: The whole procedure could be fully automated. However, it requires time, which I don't have

## Prerequisites
This deployment expects, that you have uuEE user with name 22-7709-1 and it's credentials in ~/.uu/22-7709-1
Also it must be in group ues:DTC-BT:DTC.TERRE~DEPLOYERS. This management things are not covered in this demo.

## Custom changes
Logging to Graylog is disabled. To enable it, look for LOG_DRIVER in uuApps-controller.cfg

## Preparation
generate new ssh key pair
```
ssh-keygen -f ~/.ssh/id_rsa_demo
```
put content of ~/.ssh/id_rsa_demo.pub to the terraform file to locals.sshKey

put this configuration to ~/.ssh/config
```
Host uucloud.westeurope.cloudapp.azure.com
 User uucloud
 IdentityFile ~/.ssh/id_rsa_demo
```

create your access file - it's used for appbox downloads
put file in ~/.uu/<your-uuid>
```
accessCode1=<loginname>
accessCode2=<loginpassword>
```

## Packer for creating base image
see ./packer/README.md

## Terraform for the azure environment
```
terraform init
terraform apply --auto-approve
```

## Ansible for system preparation
```
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/01_install_syshost.yml
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/2_install_registry.yml -e "target_host=syshost"
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/3_install_mongodb.yml -e "target_host=syshost"
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/30_uu_or_build.yml
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/31_uu_or_deploy.yml
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/33_uu_c3_build.yml
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/34_uu_c3_deploy.yml
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/4_install_uu_gateway_ruby_router.yml -e "target_host=syshost"
ansible-playbook -i inventory_single_vm_azure_uucloud.ini playbooks/uucloud/10_install_docker_host.yml -e "registry_hostname=syshost"
````

## Connect to host
```
cd /etc/docker/mongodb
/usr/local/bin/docker-compose up -d
cd /etc/docker/registry
/usr/local/bin/docker-compose up -d
cd /etc/docker/
./run_uu_or_demo_syshost.sh
./run_uu_c3_demo_syshost.sh
```



## Runtime stacks
```
cd /opt/installation/uu_c3/<version>/docker
```
### C3 build dependencies
Dockerfiles
- c3: FROM sync_cmd_container:1.1.0
- sync_cmd_container:1.1.0 FROM jdk8_32_tomcat7:62
- jdk8_32_tomcat7:62 FROM jdk8_32:u144
- jdk8_32:u144 FROM centos:7

```
copy files from /opt/installation/shared-files to /opt/installation/uu_c3/<version>/docker/shared-files
./build_jdk8_32.sh
./build_jdk8_32_tomcat7.sh
./build_sync_cmd_container.sh
./build_uu_c3-cmd.sh
docker tag uu_c3-cmd:2.9.3 syshost:5000/uu_c3-cmd:2.9.3
```

### uuos9_gateway_base dependencies
Dockerfiles
- uuos9_gateway_base FROM uu_os9_ruby_stack:1.0
- uu_os9_ruby_stack FROM uu_c3_centos_stack:7.0 -> see Known issues
```
./build_uu_c3_centos_stack.sh
./build_uu_os9_ruby_stack.sh
./build_uuos9_gateway_base.sh
```

# Limitations
## Deployment user
Deployment user already exists in UU. You should create your own uuEE  
Replace uuEE folder /mnt/share/uu_script_users/weyYqBQ9/22-7709-1 with your user

# Known issues
Missing "scl-utils \" in uu_c3_centos_stack/Dockerfile -> workaround add it  
Can't install ruby22 -> workaround replace with ruby24  
Workaround2: Download fixed uu_c3_centos_stack from Appbox UU-BT:UU-CLOUDG01-C3/APPBOX-2.10.11, file: uu_c3-dockerfiles-2.10.11.zip

# Hardcoded values
Like /Users/nwm/IdeaProjects/UUCloudTrainingUSY/roles in packer/centos7_with_docker.json

## uuLogstoreCMD
AppBox: UU-BT:UU-CLOUD-LOGSTOREG01/APPBOX-1.8.2  
RN: https://uuapp.plus4u.net/uu-bookkit-maing01/8e029f520c1747d3a6b5fa270fe04f15/book/page?code=rn_1
```
cd /opt/installation/uu_c3/2.9.3/docker
cp /opt/installation/shared-files/jdk-8u144-linux-i586.rpm uu_os_jruby_stack
cp /opt/installation/shared-files/uu-client.properties uu_os_jruby_stack
./build_uu_os_jruby_stack.sh
./build_uu_os_cmd_jruby_stack.sh
```

Env is missing DRMI_PORT value, probably issue with c3 script /opt/uu_c3/scripts/uuapps-controller/uuApps-controller.sh
```
docker inspect syshost:5000/dtc_bt-demo_logstorecmd-uu_logstore-demo:1.8.2
"Env": [
    ...
    "JMX_ADDR=10.0.1.101",
    "JMX_PORT=9090",
    "RMI_PORT=9091",
    "DRMI_PORT=",
```
It won't start, this is the error
```
Java HotSpot(TM) Server VM warning: Setting CompressedClassSpaceSize has no effect when compressed class pointers are not used
Error: Invalid com.sun.management.jmxremote.rmi.port number:
```
