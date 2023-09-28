#!/bin/bash

WORK_DIR=/tmp/solo_dir

LOGLEVEL="info"
# trace evm
TRACE="--trace"

ethermintd start --metrics --pruning=nothing --evm.tracer=json $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001aphoton --json-rpc.api eth,txpool,personal,net,debug,web3,miner --api.enable  --home ${WORK_DIR}


