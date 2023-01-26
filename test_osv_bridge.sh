#!/bin/bash
OSV_BRIDGE=lan-rsx217
ip address add 172.102.0.5/32 dev lan-rsx217
# brctl addif $OSV_BRIDGE $1
# brctl stp $OSV_BRIDGE off
# ifconfig $1 up
