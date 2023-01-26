#!/bin/bash
export OSV_BRIDGE_1=lan-rsx217
export OSV_BRIDGE_2=wan-rsx217
brctl addif $OSV_BRIDGE_1 $1
brctl addif $OSV_BRIDGE_2 $1
brctl stp $OSV_BRIDGE_1 off
brctl stp $OSV_BRIDGE_2 off
ip address add 172.102.0.10/32 dev $1
ip address add 172.101.0.10/32 dev $1
ifconfig $1 up
