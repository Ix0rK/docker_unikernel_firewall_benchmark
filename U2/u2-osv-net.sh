#!/bin/bash
export OSV_BRIDGE=lan-rsx217
brctl addif $OSV_BRIDGE $1
brctl stp $OSV_BRIDGE off
ip address add 172.102.0.6/32 dev $1
ifconfig $1 up
