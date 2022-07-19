# Hyperledger Fabric on GCE

Referring to Hyperledger Fabric  [doc](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html), I follow up all steps to create fabric in gce VM to running test network.

 

## Steps

1. Creat a Compute Engine VM with Ubuntu.
2. SSH into VM.
3. To get the install script.
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```
4. Install Docker and Docker-compose
 ```
 sudo apt-get update
 apt-get install docker
 apt-get install docker.io
 apt-get install docker-compose
 ```

5. To pull the Docker containers and clone the samples repo, run one of these commands for example
 ```
 ./install-fabric.sh docker samples
 ./install-fabric.sh d s
 ```
6. Install fabric
```
./install-fabric.sh 
```
7. Into test-network
8. Set the env var
```

export FABRIC_CFG_PATH=/root/fabric-samples/config/
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/tim_chiang/.local/bin:/home/tim_chiang/bin:/root/fabric-samples/bin:$PATH

# Environment variables in test-network

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```
9. Run the code
```
./network.sh down
./network.sh up
./network.sh createChannel
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript/ -ccl javascript
```

10. Initialize the ledger with assets. 
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```
11. Query the ledger
```
 peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```


Another way to install docker-compose
```
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```
-----


## Create your own blockchain network.

First of all, let's look at network.sh, you can see the mark in line 13, as the docs describe, 
the cryptogen command is not recommendation in the operation of a production network.
But in this lab, the certification was created by this command.

There are three files what we need to use.
1. compose-test-net.yaml
2. docker-compose-test-net.yaml
3. core.yaml


Create channel
```
configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/mychannel.block -channelID mychannel
osnadmin channel join --channelID mychannel --config-block ./channel-artifacts/mychannel.block -o orderer.cloudmile.com:7053 --ca-file /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/tlsca/tlsca.cloudmile.com-cert.pem --client-cert /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.crt --client-key /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.key
peer channel join -b ./channel-artifacts/mychannel.block

#peer channel fetch config config_block.pb -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com -c mychannel-1 --tls --cafile $ORDERER_CA
#configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
#jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json >$
```
Deploy chaincode
```
peer lifecycle chaincode package basic.tar.gz --path /root/a-fabric/chaincode --lang node --label test
peer lifecycle chaincode install basic.tar.gz
peer lifecycle chaincode approveformyorg  -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA -C mychannel-1 --name basic --version 1.0 --package-id test:c553bd324bab065ef0efa2a63c543abde0db0892245074bf04f2f05347c12735 --sequence 1
peer lifecycle chaincode checkcommitreadiness -C mychannel-1 --name basic --version 1.0 --sequence 1
peer lifecycle chaincode commit -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA --channelID mychannel-1 --name basic  --version 1.0 --sequence 1
peer lifecycle chaincode querycommitted -C mychannel-1 --name basic 
```

Process with Ledger
```
peer chaincode invoke -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA -C mychannel-1 -n basic --peerAddresses localhost:7051 --tlsRootCertFiles organizations/peerOrganizations/org1.cloudmile.com/peers/peer0.org1.cloudmile.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
peer chaincode query -C mychannel-1 -n basic -c '{"Args":["GetAllAssets"]}'
```

Env
```
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/cloudmile.com/tlsca/tlsca.cloudmile.com-cert.pem
```

#### Background
Two peers in same org.



----
Facing What Error?

```
Failed obtaining connection for peer0.org1.cloudmile.com:7051, PKIid:ab65a72330b964ef2c1555e83eb48cd86e9a06f6ec60a44e626ebc1d7016408d reason: context deadline exceeded
```
```
ERROR: manifest for hyperledger/fabric-orderer:latest not found
```

```
ERROR: Named volume "orderer.cloudmile.com:/var/hyperledger/production/orderer:rw" is used in service "orderer.cloudmile.com" but no declaration was found in the volumes section.
```
Docker-compose.yaml add ```volumes:```

```
Cannot run peer because cannot init crypto, specified path "" does not exist or cannot be accessed: stat : no such file or directory
```
Export env var.
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.cloudmile.com/peers/peer1.org1.cloudmile.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.cloudmile.com/users/Admin@org1.cloudmile.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

```
Server TLS handshake
```










