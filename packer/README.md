# Basics
CentoOS base image with Docker

You need to create resource group first, for the packer image
```
terraform init
terraform apply --auto-approve  
```

# Run scripts
```
source login_variables.sh
packer validate centos7_with_docker.json
packer build -on-error=ask centos7_with_docker.json
```
# Sources
https://docs.microsoft.com/cs-cz/azure/virtual-machines/linux/capture-image
https://docs.microsoft.com/cs-cz/azure/virtual-machines/linux/build-image-with-packer
