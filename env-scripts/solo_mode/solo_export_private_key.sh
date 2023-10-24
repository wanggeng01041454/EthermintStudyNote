#!/bin/bash

WORK_DIR=/tmp/solo_dir
KEY=solo_mykey
KEYRING=test
MONIKER=solo_test

# 使用管道，提前把交互命令准备好
echo "y" | ethermintd keys export ${KEY} --keyring-backend ${KEYRING} --unsafe --unarmored-hex  --home ${WORK_DIR}

