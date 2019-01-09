#!/bin/sh

CONF_FILE="$HOME/bin/vnet.ini"

if [ ! -f $CONF_FILE ]; then
    echo "Can't read config file!"
    exit 1
fi

add_veth_tap()
{
    if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
        echo "I need vnet num and veth num!"
        exit 1
    fi

    VNET=$1
    VETH_NUM=$2
    i=1
    while [ $i -le $VETH_NUM ]; do
        tunctl -t tap$VNET$i -u `id -u $USER`
        RETVAR="$?"
        ifconfig tap$VNET$i up
        i=$(($i + 1))
    done
    
    return $RETVAR
}

del_veth_tap()
{
    if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
        echo "Need vnet num and veth num!"
        exit 1
    fi

    VNET=$1
    VETH_NUM=$2
    i=1
    while [ $i -le $VETH_NUM ]; do
        tunctl -d tap$VNET$i 
        RETVAR="$?"
        i=$(($i + 1))
    done
    
    return $RETVAR
}

add_vnet()
{
    VNET_ID=$1
    VETH_NUM=$2
    VNET_ADDR=$3

    add_veth_tap $VNET_ID $VETH_NUM
    brctl addbr vn$VNET_ID
    i=1
    while [ $i -le $VETH_NUM ]; do
        brctl addif vn$VNET_ID tap$VNET_ID$i
        RETVAR="$?"
        i=$(($i + 1))
    done
    ifconfig vn$VNET_ID $VNET_ADDR

    return $RETVAR
}

del_vnet()
{
    VNET_ID=$1
    VETH_NUM=$2
    VNET_IP=$3

    del_veth_tap $VNET_ID $VETH_NUM
    ifconfig vn$VNET_ID down
    brctl delbr vn$VNET_ID
}

vnet_main()
{
    ACTION=$1
    echo $ATCION

    # get USER VNET_NUM EXITIF from config file.
    eval `confget -f $CONF_FILE -l`

    if [ "x$VNET_NUM" = "x" ] || [ "x$EXITIF" = "x" ]; then
        echo "globel config is invalid. Missing VNET_NUM or EXITIF"
        exit 1
    fi

    EXITIF_OLD=$EXITIF
    VNET_ID=1
    while [ $VNET_ID -le $VNET_NUM ]; do
        # get globle config for exitif
        EXITIF=$EXITIF_OLD
        # get each vnet config from config file
        eval `confget -f $CONF_FILE -s vnet$VNET_ID -l`
        # get ip addr after SNAT.
        EXITIF_IP=`env LANG=C ifconfig $EXITIF | sed -ne 's/\(.*\)addr:\([[:digit:].]*\)\(.*\)/\2/p'`

        if [ "x$VNET_NUM" = "x" ] || [ "x$VNET_IP" = "x" ]; then 
            echo "Lost config for vnet $VNET_ID. Check config file."
            exit 1
        fi
        
        if [ "x$ACTION" = "xstart" ]; then
            add_vnet $VNET_ID $VETH_NUM $VNET_IP
        elif [ "x$ACTION" = "xstop" ]; then
            del_vnet $VNET_ID $VETH_NUM $VNET_IP
        fi

        if [ "x$DONAT" = "xyes" ] || [ "x$DONAT" = "xy" ]; then
            if [ "x$EXITIF_IP" != "x" ]; then
                if [ "x$ACTION" = "xstart" ]; then
                    echo 1 > /proc/sys/net/ipv4/ip_forward
                    iptables -t nat -A POSTROUTING -s $VNET_IP -o $EXITIF -j SNAT --to-source $EXITIF_IP
                elif [ "x$ACTION" = "xstop" ]; then
                    iptables -t nat -D POSTROUTING -s $VNET_IP -o $EXITIF -j SNAT --to-source $EXITIF_IP
                fi
            fi
        fi
        VNET_ID=$(($VNET_ID + 1))
    done
}

case $1 in
start)
    vnet_main start
    ;;
stop)
    vnet_main stop
    ;;
*)
    echo "Usage: $0 start|stop"
    return 1
    ;;
esac
