#!/bin/bash

WORK_DIR=/tmp/solo_dir
KEY=solo_mykey

ethermintd keys export ${KEY} --unsafe --unarmored-hex  --home ${WORK_DIR}
