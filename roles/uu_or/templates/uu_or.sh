#!/bin/bash

#UNCOMMENT AND SET THE FOLLOWING VARIABLES!!!
OR_CONTAINER_NAME="uu_or-cmd_{{ environment_name | lower }}_{{ inventory_hostname_short }}_{{ uu_or_appbox_version }}"

# Fluent variables (required):
APP_DEPLOYMENT_URI="ues:[99923616732520257]:[{{ environment_name | lower }}]:[{{ environment_name | lower }}]"
HOST_ID="{{ inventory_hostname_short }}"
HOST_NAME="{{ inventory_hostname }}"
NODE_ID="{{ inventory_hostname_short }}"
NODE_NAME="{{ inventory_hostname_short }}"
NODE_IMAGE_ID="uu_or-cmd:{{ uu_or_appbox_version }}"
NODE_IMAGE_NAME="uu_or-cmd:{{ uu_or_appbox_version }}"
RESOURCE_GROUP_ID="{{ resource_group_name }}"
RESOURCE_GROUP_CODE="{{ resource_group_name }}"
RUNTIME_STACK_ID="CMD_JRUBY_V1.0"
RUNTIME_STACK_CODE="CMD_JRUBY_V1.0"

# OR required environment variables:
DB_CONNECTION_URI="{{ or_mongo_connection_string }}"
OPER_REG_ACCESS_GROUP="ues:DTC-BT:DTC.TERRE~ADM"
CLOUD_CODE="{{ cloud_code }}"
CLOUD_NAME="{{ cloud_code }}"
OPERATION_TERRITORY_OID="99923616732520257"
OPERATION_TERRITORY_CODE="DTC-BT"
MSG_BUS_DEFAULT_QUEUE_LIMIT="2"

# OR optional environment variables:
#OPER_REG_AUTH_ENABLED=

CONNECTOR_PORT="{{ or_connector_port }}"
FLUENTD_ADDRESS="localhost:24224"

# Memory limit for the OR container.
MEMORY="{{ or_memory }}"

# XMX (JVM heap size) of a java stack node is calculated by the following formula:
# XMX = MEMORY * 0.8 - JAVA_STACK_OS_MEM_RESERVE
# The purpose of JAVA_STACK_OS_MEM_RESERVE is to be able to leave more memory for OS
# if needed.
# The default value -- 80MB -- should be sufficient
JAVA_STACK_OS_MEM_RESERVE="80"

# IP address of the docker host where the OR container is about to be run (required)
DHOST_IP="{{ ansible_host }}"

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
    if (( $XMX < $XMX_INTERVAL_1 )); then
      # 250 <= MEMORY < 500
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=32m -XX:MaxMetaspaceSize=32m -XX:InitialCodeCacheSize=20m -XX:ReservedCodeCacheSize=20m -XX:CompressedClassSpaceSize=10m"
    elif (( $XMX < $XMX_INTERVAL_2 )); then
      # 500 <= MEMORY < 1000
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=64m -XX:InitialCodeCacheSize=36m -XX:ReservedCodeCacheSize=36m -XX:CompressedClassSpaceSize=12m"
    elif (( $XMX < $XMX_INTERVAL_3 )); then
      # 1000 <= MEMORY < 2000
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=84m -XX:MaxMetaspaceSize=84m -XX:InitialCodeCacheSize=80m -XX:ReservedCodeCacheSize=80m -XX:CompressedClassSpaceSize=16m"
    elif (( $XMX < $XMX_INTERVAL_4 )); then
      # 2000 <= MEMORY < 5000
      CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=100m -XX:MaxMetaspaceSize=100m -XX:InitialCodeCacheSize=125m -XX:ReservedCodeCacheSize=125m -XX:CompressedClassSpaceSize=40m"
    else
      # 5000 <= MEMORY
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

#DOCKER_JMX_PORT=$(random_port)
DOCKER_JMX_PORT="4201"
DOCKER_RMI_PORT=${DOCKER_JMX_PORT}

MEMORY_LIMIT=""
if [ ! -z "$MEMORY" ]; then MEMORY_LIMIT=" -m ${MEMORY}m"; fi

define_catalina_opts

# Set default value for container name if unset
if [ -z "$OR_CONTAINER_NAME" ]; then
  OR_CONTAINER_NAME="uu_or-cmd"
fi

docker run -d --restart=always \
-p "$CONNECTOR_PORT:8080" \
-p "${DOCKER_JMX_PORT}:${DOCKER_JMX_PORT}" \
--log-opt tag="{% raw %}docker.{{.Name}}{% endraw %}" \
-e UU_CLOUD_APP_DEPLOYMENT_URI="$APP_DEPLOYMENT_URI" \
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
-e DB_CONNECTION_URI="$DB_CONNECTION_URI" \
-e MSG_BUS_DEFAULT_QUEUE_LIMIT="$MSG_BUS_DEFAULT_QUEUE_LIMIT" \
-e OPER_REG_ACCESS_GROUP="$OPER_REG_ACCESS_GROUP" \
-e CLOUD_CODE="$CLOUD_CODE" \
-e CLOUD_NAME="$CLOUD_NAME" \
-e OPERATION_TERRITORY_OID="$OPERATION_TERRITORY_OID" \
-e OPERATION_TERRITORY_CODE="$OPERATION_TERRITORY_CODE" \
-e OPER_REG_AUTH_ENABLED="$OPER_REG_AUTH_ENABLED" \
-e CATALINA_OPTS="$CATALINA_OPTS" \
--log-opt env=\
UU_CLOUD_APP_DEPLOYMENT_URI,\
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
--name "$OR_CONTAINER_NAME" {{ registry_hostname }}:{{ registry_port }}/uu_or-cmd:{{ uu_or_appbox_version }}

# removed log-opts for debug reasons
#--log-driver=fluentd \
#--log-opt fluentd-address="$FLUENTD_ADDRESS" \
