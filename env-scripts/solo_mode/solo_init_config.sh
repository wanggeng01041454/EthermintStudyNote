#!/bin/bash

# 默认的工作目录为 $HOME/.ethermintd
# 通过 --home <dir> 命令修改默认工作目录
WORK_DIR=/tmp/solo_dir

# 没有时创建，有时清空
rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}

# ###########################################

MONIKER=solo_test
# CHAINID=7788
# TODO CHAINID 的取值， "ethermint_9000-1" 是可用的， 7788 是不可用的，"ethermint-7788" 也是不可用的
# 这样配置，实际的chainId是9955
CHAINID=ethermint_9955-7788

# 生成初始配置，设置 moniker(节点别名) 和 chain-id
ethermintd init ${MONIKER} --chain-id=${CHAINID} --home ${WORK_DIR}
# 这一步会生成 config 目录，和 data 目录
# 执行该命令后，cd $WORK_DIR && tree 的执行结果为：
# .
# ├── config
# │   ├── app.toml
# │   ├── client.toml
# │   ├── config.toml
# │   ├── genesis.json
# │   ├── node_key.json
# │   └── priv_validator_key.json
# └── data
#     └── priv_validator_state.json
#
# 2 directories, 7 files

# ###########################################

KEY=solo_mykey
KEYRING=test
KEYALGO=eth_secp256k1

# 配置 keyring-backend， 默认取值为 os 
# keyring-backend 的取值集合： os|file|kwallet|pass|test|memory
ethermintd config keyring-backend ${KEYRING}  --home ${WORK_DIR}

# 创建账户
ethermintd keys add ${KEY} --keyring-backend ${KEYRING} --algo ${KEYALGO} --home ${WORK_DIR}
# 这一步会触发创建 keyring-test 目录，它的目录结构为
# tree keyring-test/
# keyring-test/
# ├── 45f66e94ff8c91d63617ad5835ad514f4c1a5c0d.address
# └── solo_mykey.info
#
# 0 directories, 2 files


# ###########################################
# 通过命令行调整 genesis.json 配置文件中的默认配置


# 原始文件
ORI_FILE=${WORK_DIR}/config/genesis.json
TMP1_FILE=/tmp/genesis_tmp_1.json
TMP2_FILE=/tmp/genesis_tmp_2.json

# 将所有的货币单位调整为 TOKEN_UNIT
cp $ORI_FILE ${TMP1_FILE}

# jq 命令后的字符串中不能使用bash的环境变量，所以无法使用 TOKEN_UNIT
# TOKEN_UNIT=aphoton
cat ${TMP1_FILE} | jq '.app_state["staking"]["params"]["bond_denom"]="aphoton"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

cat ${TMP1_FILE} | jq '.app_state["crisis"]["constant_fee"]["denom"]="aphoton"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

cat ${TMP1_FILE} | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aphoton"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

cat ${TMP1_FILE} | jq '.app_state["mint"]["params"]["mint_denom"]="aphoton"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

# 这是我自己加的，根据搜索 denom 关键字找到的
cat ${TMP1_FILE} | jq '.app_state["evm"]["params"]["evm_denom"]="aphoton"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

# 设置gas limit 值，默认为-1，表示不限制; 30,000,000 和以太坊的值一致
cat ${TMP1_FILE} | jq '.consensus_params["block"]["max_gas"]="30000000"' > ${TMP2_FILE} 
mv ${TMP2_FILE} ${TMP1_FILE}

mv ${TMP1_FILE} ${ORI_FILE}


# Allocate genesis accounts (cosmos formatted addresses)
ethermintd add-genesis-account $KEY 100000000000000000000000000aphoton --keyring-backend $KEYRING --home ${WORK_DIR}

# Sign genesis transaction
ethermintd gentx $KEY 1000000000000000000000aphoton --keyring-backend $KEYRING --chain-id $CHAINID --home ${WORK_DIR}

# Collect genesis tx
ethermintd collect-gentxs --home ${WORK_DIR}

# Run this to ensure everything worked and that the genesis file is setup correctly
ethermintd validate-genesis --home ${WORK_DIR}



# ###########################################

# 使用 sed 修改配置文件
# 设置 create_empty_blocks = false
sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' ${WORK_DIR}/config/config.toml
# 设置 prometheus = true
sed -i 's/prometheus = false/prometheus = true/' ${WORK_DIR}/config/config.toml
# 设置 prometheus-retention-time  = "1000000000000"
sed -i 's/prometheus-retention-time  = "0"/prometheus-retention-time  = "1000000000000"/g' ${WORK_DIR}/config/app.toml
# 设置 enabled = true
sed -i 's/enabled = false/enabled = true/g' ${WORK_DIR}/config/app.toml

# 将所有127.0.0.1替换为0.0.0
sed -i 's/address = "127.0.0.1:8545"/address = "0.0.0.0:8545"/g' ${WORK_DIR}/config/app.toml
sed -i 's/ws-address = "127.0.0.1:8546"/ws-address = "0.0.0.0:8546"/g' ${WORK_DIR}/config/app.toml
# ###########################################



