#!/bin/bash

#Docker entry point for AL Agent inside Kubernetes Pods
#AL Agent will capture network traffic from Pods Pause container network interface
#AL Agent will listen for syslog message on TCP 1514

file="/var/alertlogic/etc/host_crt.pem"
ACTION=$1
HOST=$2
ALERTLOGIC_KEY=$3
API_KEY=$4
CID=$5
DC=$6

case "$ACTION" in
'start')
    #Check for the host_crt file to indicate if AL Agent has been provisioned previously (i.e container stop and restarted)
    #If the file exist, start the agent directly, otherwise will attempt to provision
    if [ -f "$file" ]
    then
            echo "`date` - AL Agent provisioned - starting AL Agent now"
            /etc/init.d/al-agent start
    else
            if [ ! -z "$ALERTLOGIC_KEY" ] && [ ! -z "$HOST" ]
            then
                    echo "`date` - AL Agent not provisioned - will attempt to provision with the given key and set host destination"
                    /etc/init.d/al-agent provision --key $ALERTLOGIC_KEY --host $HOST
                    /etc/init.d/al-agent start
            elif [ ! -z "$ALERTLOGIC_KEY" ]
            then
                    echo "`date` - AL Agent not provisioned - will attempt to provision with the given key"
                    /etc/init.d/al-agent provision --key $ALERTLOGIC_KEY
                    /etc/init.d/al-agent start
            elif [ ! -z "$HOST" ]
            then
                    echo "`date` - AL Agent not provisioned - will attempt auto claim and set host destination"
                    /etc/init.d/al-agent provision --host $HOST
                    /etc/init.d/al-agent start
            else
                    echo "`date` - AL Agent not provisioned - will attempt auto claim"
                    /etc/init.d/al-agent start
            fi
    fi
;;

'provision')
    echo "`date` - Provision AL Agent with the given key and set host destination"
    /etc/init.d/al-agent provision --key $ALERTLOGIC_KEY --host $HOST

;;

'configure')
    echo "`date` - Configure AL Agent with the given key and set host destination"
    /etc/init.d/al-agent configure --key $ALERTLOGIC_KEY --host $HOST

;;

*)
    echo "`date` - Invalid input, use [start/provision/configure] [host ip] [REG_KEY] [API_KEY] [CID] [DC] as parameters"
;;

esac

#Perform API call to do house-keeping when the container receive SIGTERM
#Requires $API_KEY and $CID to be provided as argument from docker-entrypoint.sh
function clean_up {

    CURL="curl -fsS -X DELETE -H 'Accept: application/json'"
    HEADERS="{'content-type': 'application/json'}"

    #Select data center to determine API end point
    case "$DC" in
    'DEN')
        TM_URL="https://publicapi.alertlogic.net/api/tm/v1"
        SOURCES_URL="https://publicapi.alertlogic.net/api/lm/v1"
    ;;

    'ASH')
        TM_URL="https://publicapi.alertlogic.com/api/tm/v1"
        SOURCES_URL="https://publicapi.alertlogic.com/api/lm/v1"
    ;;

    'NPT')
        TM_URL="https://publicapi.alertlogic.co.uk/api/tm/v1"
        SOURCES_URL="https://publicapi.alertlogic.co.uk/api/lm/v1"
    ;;

    *)
        TM_URL="https://publicapi.alertlogic.net/api/tm/v1"
        SOURCES_URL="https://publicapi.alertlogic.net/api/lm/v1"
    ;;

    esac
    
    #Get UUID from configuration file
    PHOST_CONF="/var/alertlogic/lib/agent/etc/tmhost.conf"
    SLC_CONF="/var/alertlogic/lib/agent/etc/slc.conf"

    HOST_ID=$(strings $PHOST_CONF | head -1 | cut -d$ -f3)
    PHOST_ID=$(strings $PHOST_CONF | head -1 | cut -d$ -f2 | cut -c1-36)
    SOURCE_ID=$(strings $SLC_CONF | head -1 | cut -d$ -f2)

    #DELETE SOURCE
    CMD="$CURL -u $API_KEY: '$SOURCES_URL/$CID/sources/$SOURCE_ID'"    
    OUT=$(eval "$CMD" 2>&1)    

    #DELETE PHOST
    CMD="$CURL -u $API_KEY: '$TM_URL/$CID/protectedhosts/$PHOST_ID'"    
    OUT=$(eval "$CMD" 2>&1)    

    #DELETE HOST
    CMD="$CURL -u $API_KEY: '$TM_URL/$CID/hosts/$HOST_ID'"    
    OUT=$(eval "$CMD" 2>&1)    

    exit 143; # 128 + 15 -- SIGTERM
}

#Check if host clean up is requested
if [ ! -z "$API_KEY" ] && [ ! -z "$CID" ]
then
        echo "`date` - Alert Logic API Key and CID provided, will attempt to trap SIGTERM and run clean up when this container receive terminate signal from daemon"
        
        #trap SIGTERM, kill the last process (tail -f) then execute the clean_up
        trap 'kill ${!}; clean_up' SIGTERM

        while true
        do 
            tail -f /dev/null & wait ${!}
        done
else
        echo "`date` - No Alert Logic API key or CID provided"
        tail -f /dev/null & wait ${!}
fi
