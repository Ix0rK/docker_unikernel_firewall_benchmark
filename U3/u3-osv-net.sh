#!/bin/bash
export OSV_BRIDGE=wan-rsx217
brctl addif $OSV_BRIDGE $1
brctl stp $OSV_BRIDGE off
ip address add 172.101.0.11/32 dev $1
ifconfig $1 up
