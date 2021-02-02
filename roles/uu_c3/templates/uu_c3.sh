#!/bin/bash
#set -Eeuo pipefail

#UNCOMMENT AND SET THE FOLLOWING VARIABLES!!!
C3_CONTAINER_NAME="uu_c3-cmd_{{ environment_name | lower }}_{{ inventory_hostname_short }}_{{ uu_c3_appbox_version }}"

# Fluent variables (required):
LOG_SOURCE_URI="ues:[99923616732520257]:[{{ environment_name | lower }}]:[{{ environment_name | lower }}]"
HOST_ID="{{ inventory_hostname_short }}"
HOST_NAME="{{ inventory_hostname }}"
NODE_ID="{{ inventory_hostname_short }}"
NODE_NAME="{{ inventory_hostname_short }}"
NODE_IMAGE_ID="uu_or-cmd:{{ uu_c3_appbox_version }}"
NODE_IMAGE_NAME="uu_or-cmd:{{ uu_c3_appbox_version }}"
RESOURCE_GROUP_ID="{{ resource_group_name }}"
RESOURCE_GROUP_CODE="{{ resource_group_name }}"
RUNTIME_STACK_ID="CMD_JRUBY_V1.0"
RUNTIME_STACK_CODE="CMD_JRUBY_V1.0"

# C3 required environment variables:
SERVER_CFG='{"uu.operation.registry.base_url":"{{ uu_or_base_url }}"}'
C3_ACCESS_GROUP="ues:DTC-BT:DTC.TERRE~ADM"
C3_APP_CREDENTIALS="/mnt/share/uu_script_users/weyYqBQ9/22-7709-1"
CLOUD_CODE="{{ cloud_code }}"
CLOUD_NAME="{{ cloud_code }}"
OPERATION_TERRITORY_OID="99923616732520257"
OPERATION_TERRITORY_CODE="DTC-BT"
DOCKER_REPO="{{ registry_hostname }}:5000"
DOCKER_URL="http://{{ registry_hostname }}:4243"
#AZURE_AD_TENANT_ID=
#AZURE_C3_CLIENT_ID=
#AZURE_C3_CLIENT_SECRET=
#AZURE_CDN_SUBSCRIPTION_ID=
#AZURE_CDN_RESGROUP_NAME=
#AZURE_CDN_PROFILE_NAME=
#AZURE_CDN_ENDPOINT_NAME=
#CDN_STORAGE_USER=
#CDN_STORAGE_ROOT_PATH=
#CDN_UPLOAD_STRATEGY=
#CDN_ALIAS_STRATEGY=
#CDN_BACKUP_STORAGE_CODE=
#CDN_ORIGIN_STORAGE_CODE_PREFIX=
#CDN_PROD_ACCESS_GROUP=
#CDN_CACHE_STRATEGY=
DOCKER_API_PORT=4243

# This is MongoDB connection string which is used for incremental
# gateway update. Does not have to be set if this feature is not used.
# Example:
#   GW_DB_CONNECTION_URI="mongodb://10.0.2.10"
# For format details see https://docs.mongodb.com/manual/reference/connection-string/
#GW_DB_CONNECTION_URI=

# This variable is used for containers (services), which
# are deployed to ResourceGroup with "nodeProvider: SWARM"
LOGSTORE_COLLECTOR_ADDRESS=127.17.0.1:24224

# Do Zabbixu se registrujou jen legacy uuApps. Aplikace podle standardu uuAppg01 se tam aktuálně neregistrujou.
# Z pohledu API se volá create/delete host a každý Docker kontejner (uuNode) je tam reprezentován hostem.
# Hosti se do Zabbixu vytvářejí do skupiny "CMD 2.0 - uuApps Nodes" podle template "UU Template Service Tomcat cmd 2.0",
# ale Zabbix není součástí dokumentace uuCloudu.
# Volání Zabbix API z C3 je vidět ve skriptu uuapps-controller/zabbix.rb, který je součástí uuCloudg01C3.
# Volá se to v rámci commandů AppDeployment/deploy a AppDeployment/undeploy a pokud to nastaveno nebude, tak se budou logovat chybové hlášky, že se nelze připojit na Zabbix :/
# vyřadit z používání by to šlo jedině zakomentováním řádků v uuApps-controller.sh, které volající runner_zabbix.sh - ale to je vyloženě hack

#ZABBIX_URL=
#ZABBIX_USER=
#ZABBIX_PASSWORD=

# C3 optional environment variables:
#DHOST_COMMON_CONTAINERS=
BUILDER_HOST="{{ builder_host_user }}@{{ registry_hostname }}"
C3_AUTH_ENABLED="true"
SCRIPT_EXECUTION_TIMEOUT="900"
UUEE_WHITELIST_TTL="900"
UUEE_WHITELIST_MODE="lenient"
API_BASE_URL="api.plus4u.net"
DOCKER_API_CONNECT_TIMEOUT="600"
DOCKER_API_READ_TIMEOUT="600"
DOCKER_API_WRITE_TIMEOUT="600"
#CDN_PACK_FILES_LIMIT=
#ALLOW_CDN_PACK_DEPLOY=
#TRUST_SERVER_HOSTNAME=
#TRUST_SERVER_CERT=
#THREAD_COUNT=
#GATEWAY_LOCK_TIMEOUT=
#CHECK_CONTAINERS_STILL_RUNNING=
#SWARM_VALIDATE_RUNNING_SERVICE=
#SWARM_VALIDATION_RUNNING_DELAY_SEC=
#SWARM_VALIDATION_RUNNING_TIMEOUT_SEC=


# Path (on host where uu_c3-cmd will be running)
# to directory containing uuEE password files
HOST_UUEES_PATH=/mnt/share/uu_script_users

# Path (on host where uu_c3-cmd will be running)
# to directory where c3 logs will be stored
HOST_C3_LOGS_PATH=/var/log/c3_logs
mkdir -p ${HOST_C3_LOGS_PATH}
CONTAINER_LOG_DIR="$(mktemp -d -p "${HOST_C3_LOGS_PATH}" "${C3_CONTAINER_NAME}-$(date +%s)"-XXX)"

CONNECTOR_PORT="{{ c3_connector_port }}"

FLUENTD_ADDRESS="localhost:24224"
# Memory limit for the c3 container.
MEMORY="{{ c3_memory }}"
# XMX (JVM heap size) of a java stack node is calculated by the following formula:
# XMX = MEMORY * 0.8 - JAVA_STACK_OS_MEM_RESERVE
# The purpose of JAVA_STACK_OS_MEM_RESERVE is to be able to leave more memory for OS
# if needed.
# The default value -- 80MB -- should be sufficient
JAVA_STACK_OS_MEM_RESERVE="80"

# IP address of the docker host where the C3 container is about to be run (required)
DHOST_IP="{{ ansible_host }}"

# Set default value for container name if unset
if [ -z "$C3_CONTAINER_NAME" ]; then C3_CONTAINER_NAME="uu_c3-cmd"; fi

function random_port() {
  count=0
  while [[ $count -le 49 ]]; do
    (( count++ ))
    # 2000..33500
    port=$((RANDOM + 2000))
    while [[ $port -gt 33500 ]]; do
      port=$((RANDOM + 2000))
    done
    # 2000..65001
    [[ $((RANDOM % 2)) = 0 ]] && port=$((port + 31501))
    # 2000..65000
    [[ $port = 65001 ]] && continue
    [[ `netstat -lntu | grep $port` ]] && continue
    echo $port
    break
  done
}

function define_catalina_opts() {
  CATALINA_OPTS="$CATALINA_OPTS -Djava.security.egd=file:///dev/urandom"

  XMX=`echo "$MEMORY*0.8-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`
  JVM_MAX_RAM=`echo "$MEMORY-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`

  local XMX_INTERVAL_1=`echo "500*0.8-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`
  local XMX_INTERVAL_2=`echo "1000*0.8-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`
  local XMX_INTERVAL_3=`echo "2000*0.8-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`
  local XMX_INTERVAL_4=`echo "5000*0.8-$JAVA_STACK_OS_MEM_RESERVE" | bc | awk -F'.' '{print $1}'`

  CATALINA_OPTS="$CATALINA_OPTS -Djava.rmi.server.hostname=$DHOST_IP"
  CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.port=${DOCKER_JMX_PORT}"
  CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.rmi.port=${DOCKER_RMI_PORT}"

  # Configure java memory, based on used node size (i.e. MEMORY size)
  if [ ! -z "$XMX" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -Xms${XMX}m -Xmx${XMX}m"
    # 250 <= MEMORY < 500
    if (( $XMX < $XMX_INTERVAL_1 )); then
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=32m -XX:MaxMetaspaceSize=32m -XX:InitialCodeCacheSize=20m -XX:ReservedCodeCacheSize=20m -XX:CompressedClassSpaceSize=10m"
    # 500 <= MEMORY < 1000
    elif (( $XMX < $XMX_INTERVAL_2 )); then
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=64m -XX:InitialCodeCacheSize=36m -XX:ReservedCodeCacheSize=36m -XX:CompressedClassSpaceSize=12m"
    # 1000 <= MEMORY < 2000
    elif (( $XMX < $XMX_INTERVAL_3 )); then
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=84m -XX:MaxMetaspaceSize=84m -XX:InitialCodeCacheSize=80m -XX:ReservedCodeCacheSize=80m -XX:CompressedClassSpaceSize=16m"
    # 2000 <= MEMORY < 5000
    elif (( $XMX < $XMX_INTERVAL_4 )); then
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=100m -XX:MaxMetaspaceSize=100m -XX:InitialCodeCacheSize=125m -XX:ReservedCodeCacheSize=125m -XX:CompressedClassSpaceSize=40m"
    # 5000 <= MEMORY
    else
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=300m -XX:MaxMetaspaceSize=300m -XX:InitialCodeCacheSize=200m -XX:ReservedCodeCacheSize=200m -XX:CompressedClassSpaceSize=60m"
    fi
  fi

  # Set common JMX options
  CATALINA_OPTS="$CATALINA_OPTS \
    -Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.ssl=false\
    -Dcom.sun.management.jmxremote.authenticate=false\
    -Dcom.sun.management.jmxremote.local.only=false\
    -XX:NativeMemoryTracking=detail\
    -XX:+UnlockDiagnosticVMOptions\
    -XX:+PrintNMTStatistics\
    -XX:MaxRAM=$JVM_MAX_RAM\
    -server"
}

#echo $CATALINA_OPTS
DOCKER_JMX_PORT="4301"
DOCKER_RMI_PORT=$DOCKER_JMX_PORT

MEMORY_LIMIT=""
if [ ! -z "$MEMORY" ]; then MEMORY_LIMIT=" -m ${MEMORY}m"; fi

define_catalina_opts


docker run -d --restart=always \
-p "$CONNECTOR_PORT:8080" \
-p "${DOCKER_JMX_PORT}:${DOCKER_JMX_PORT}" \
-v "$HOST_UUEES_PATH":/mnt/share/uu_script_users/ \
-v "${HOST_C3_LOGS_PATH}":/opt/uu_c3_logs/ \
-v "${CONTAINER_LOG_DIR}":/opt/uu_c3_logs/.write/ \
$MEMORY_LIMIT \
$JAVA_PORTS \
$JAVA_ENV_VARIABLES \
--log-opt tag="{% raw %}docker.{{.Name}}{% endraw %}" \
-e CATALINA_OPTS="$CATALINA_OPTS" \
-e UU_CLOUD_LOG_SOURCE_URI="$LOG_SOURCE_URI" \
-e UU_CLOUD_HOST_ID="$HOST_ID" \
-e UU_CLOUD_HOST_NAME="$HOST_NAME" \
-e UU_CLOUD_NODE_ID="$NODE_ID" \
-e UU_CLOUD_NODE_NAME="$NODE_NAME" \
-e UU_CLOUD_NODE_IMAGE_ID="$NODE_IMAGE_ID" \
-e UU_CLOUD_NODE_IMAGE_NAME="$NODE_IMAGE_NAME" \
-e UU_CLOUD_RESOURCE_GROUP_ID="$RESOURCE_GROUP_ID" \
-e UU_CLOUD_RESOURCE_GROUP_CODE="$RESOURCE_GROUP_CODE" \
-e UU_CLOUD_RUNTIME_STACK_ID="$RUNTIME_STACK_ID" \
-e UU_CLOUD_RUNTIME_STACK_CODE="$RUNTIME_STACK_CODE" \
-e SERVER_CFG="$SERVER_CFG" \
-e C3_ACCESS_GROUP="$C3_ACCESS_GROUP" \
-e C3_APP_CREDENTIALS="$C3_APP_CREDENTIALS" \
-e CLOUD_CODE="$CLOUD_CODE" \
-e CLOUD_NAME="$CLOUD_NAME" \
-e OPERATION_TERRITORY_OID="$OPERATION_TERRITORY_OID" \
-e OPERATION_TERRITORY_CODE="$OPERATION_TERRITORY_CODE" \
-e DOCKER_REPO="$DOCKER_REPO" \
-e DOCKER_URL="$DOCKER_URL" \
-e ZABBIX_URL="$ZABBIX_URL" \
-e ZABBIX_USER="$ZABBIX_USER" \
-e ZABBIX_PASSWORD="$ZABBIX_PASSWORD" \
-e BUILDER_HOST="$BUILDER_HOST" \
-e C3_AUTH_ENABLED="$C3_AUTH_ENABLED" \
-e SCRIPT_EXECUTION_TIMEOUT="$SCRIPT_EXECUTION_TIMEOUT" \
-e UUEE_WHITELIST_TTL="$UUEE_WHITELIST_TTL" \
-e UUEE_WHITELIST_MODE="$UUEE_WHITELIST_MODE" \
-e API_BASE_URL="$API_BASE_URL" \
-e DOCKER_API_PORT="$DOCKER_API_PORT" \
-e DOCKER_API_CONNECT_TIMEOUT="$DOCKER_API_CONNECT_TIMEOUT" \
-e DOCKER_API_READ_TIMEOUT="$DOCKER_API_READ_TIMEOUT" \
-e DOCKER_API_WRITE_TIMEOUT="$DOCKER_API_WRITE_TIMEOUT" \
-e DHOST_COMMON_CONTAINERS="$DHOST_COMMON_CONTAINERS" \
-e CDN_PACK_FILES_LIMIT="$CDN_PACK_FILES_LIMIT" \
-e ALLOW_CDN_PACK_DEPLOY="$ALLOW_CDN_PACK_DEPLOY" \
-e TRUST_SERVER_HOSTNAME="$TRUST_SERVER_HOSTNAME" \
-e TRUST_SERVER_CERT="$TRUST_SERVER_CERT" \
-e THREAD_COUNT="$THREAD_COUNT" \
-e LOGSTORE_COLLECTOR_ADDRESS="$LOGSTORE_COLLECTOR_ADDRESS" \
-e GATEWAY_LOCK_TIMEOUT="$GATEWAY_LOCK_TIMEOUT" \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/uu-client.properties:/root/.uu/config/uu-client.properties \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/log4r.xml:/root/.uu/config/log4r.xml \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/uu-client.properties:/var/uucloud_image_builder/uu-client.properties \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/executor_controller.cfg:/opt/uu_c3/scripts/uuapps-jobexec-controller/executor_controller.cfg \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/uuApps-controller.cfg:/opt/uu_c3/scripts/uuapps-controller/uuApps-controller.cfg \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/uuGatewayController.cfg:/opt/uu_c3/scripts/uugateway-controller/uuGatewayController.cfg \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/buildImage.sh:/opt/uu_c3/scripts/uuapps-image-builder/buildImage.sh \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/ssh_config:/root/.ssh/config \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/id_rsa:/root/.ssh/id_rsa \
-v /etc/docker/uu_c3_{{ environment_name | lower }}/id_rsa.pub:/root/.ssh/id_rsa.pub \
--log-opt env=\
UU_CLOUD_LOG_SOURCE_URI,\
UU_CLOUD_HOST_ID,\
UU_CLOUD_HOST_NAME,\
UU_CLOUD_NODE_ID,\
UU_CLOUD_NODE_NAME,\
UU_CLOUD_NODE_IMAGE_ID,\
UU_CLOUD_NODE_IMAGE_NAME,\
UU_CLOUD_RESOURCE_GROUP_ID,\
UU_CLOUD_RESOURCE_GROUP_CODE,\
UU_CLOUD_RUNTIME_STACK_ID,\
UU_CLOUD_RUNTIME_STACK_CODE \
--name "$C3_CONTAINER_NAME" {{ registry_hostname }}:{{ registry_port }}/uu_c3-cmd:{{ uu_c3_appbox_version }}

# removed log-opts for debug reasons
#--log-driver=fluentd \
#--log-opt fluentd-address="$FLUENTD_ADDRESS" \
# added volume for uu-client.properties
# /root/.uu/config/uu-client.properties
# /var/uucloud_image_builder/uu-client.properties
# added volumes for controllers