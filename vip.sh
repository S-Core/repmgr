#!/bin/bash

# This code assigns IP address to interface.


USAGE="$0 [add/del] interface_name ip_address/prefix"

# CHECK argument count

if [ "$#" -ne 3 ]
then
	echo $USAGE
	exit 1
fi


# CHECK First Parameter

if [ "$1" == "add" ]
then
	TYPE="add"
elif [ "$1" == "del" ]
then
	TYPE="del"
else
	echo $USAGE
	exit 1
fi

# CHECK interface_name

if [[ $(ip link show dev $2) ]]
then
	NIC="$2"
else
	echo "Please check Interface name."
	exit 1
fi

# CHECK IP Address and prefix
if [[ $3 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]
then
	IP=$(echo "$3" | cut -d/ -f1)
	PREFIX=$(echo "$3" | cut -d/ -f2)
	for i in 1 2 3 4
	do
		if [ $(echo "$IP" |cut -d. -f$i) -gt 255 ]
		then
			echo "Please Check IP Address"
			exit 1
		fi
	done

	if [ $PREFIX -gt 32 ]
	then
		echo "Please Check IP Address"
		exit 1
	fi
else
	echo "Please Check IP Address"
	exit 1
fi

# add/del IP Address to Interface
if [ "$TYPE" == "add" ]
then
	if [[ $(ip addr | grep $IP) ]]
	then
		echo "VIP address is already binded"
		exit 0
	else
		sudo ip addr $TYPE $IP/$PREFIX dev $NIC label $NIC:1
	fi
else
	if [[ $(ip addr | grep $IP) ]]
	then
        sudo ip addr $TYPE $IP/$PREFIX dev $NIC label $NIC:1
	else
		echo "VIP address is already removed"
		exit 0
	fi
fi
