#!/bin/bash
OSV_BRIDGE=virbr0
brctl addif \$OSV_BRIDGE \$1
brctl stp \$OSV_BRIDGE off
ifconfig \$1 up
EOF
