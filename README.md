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

#### Background
Two peers in org1.

Here is the tree of structure for peer node
```
.
├── chaincode
│   ├── index.js
│   ├── lib
│   │   └── assetTransfer.js
│   ├── package.json
│   └── test
│       └── assetTransfer.test.js
├── channel-artifacts
│   └── mychannel.block
├── compose
│   ├── compose-test-net.yaml
│   └── docker
│       ├── docker-compose-test-net.yaml
│       └── peercfg
│           └── core.yaml
├── config
│   └── core.yaml
├── configtx
│   └── configtx.yaml
├── createChannel.sh
├── network.sh
└── organizations
    ├── cryptogen
    │   └── crypto-config-orderer.yaml
    ├── ordererOrganizations
    │   └── cloudmile.com
    │       ├── ca
    │       ├── msp
    │       ├── orderers
    │       │   └── orderer.cloudmile.com
    │       ├── tlsca
    │       └── users
    │           └── Admin@cloudmile.com
    └── peerOrganizations
        └── org1.cloudmile.com
            ├── ca
            ├── msp
            ├── peers
            │   ├── peer0.org1.cloudmile.com
            │   └── peer1.org1.cloudmile.com
            ├── tlsca
            └── users
                ├── Admin@org1.cloudmile.com
                └── User1@org1.cloudmile.com
```

Generate TLS with cryptogen and each VMs must have same key.
```
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
```
Generate mychannel.block with configtxgen for channel.
``
configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/mychannel.block -channelID mychannel
``

Create channel, only create one time with osnadmin, rest of VMs only need to run peer channel join. 
```
osnadmin channel join --channelID mychannel --config-block ./channel-artifacts/mychannel.block -o orderer.cloudmile.com:7053 --ca-file /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/tlsca/tlsca.cloudmile.com-cert.pem --client-cert /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.crt --client-key /root/a-fabric/organizations/ordererOrganizations/cloudmile.com/orderers/orderer.cloudmile.com/tls/server.key
peer channel join -b ./channel-artifacts/mychannel.block

#peer channel fetch config config_block.pb -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com -c mychannel --tls --cafile $ORDERER_CA
#configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
#jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json >$
```


Env
```
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/cloudmile.com/tlsca/tlsca.cloudmile.com-cert.pem
```

Deploy chaincode,  Noted: --package-id 
```
peer lifecycle chaincode package basic.tar.gz --path /root/a-fabric/chaincode --lang node --label test
peer lifecycle chaincode install basic.tar.gz
peer lifecycle chaincode approveformyorg  -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA -C mychannel --name basic --version 1.0 --package-id test:086a89c94b4bdd639cb1c21942cb383186d5fd27bbc823c9b2fa3dab8699b969 --sequence 1
peer lifecycle chaincode checkcommitreadiness -C mychannel --name basic --version 1.0 --sequence 1
peer lifecycle chaincode commit -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA --channelID mychannel --name basic  --version 1.0 --sequence 1
peer lifecycle chaincode querycommitted -C mychannel --name basic 
```

Process with Ledger
```
peer chaincode invoke -o orderer.cloudmile.com:7050 --ordererTLSHostnameOverride orderer.cloudmile.com --tls --cafile $ORDERER_CA -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles organizations/peerOrganizations/org1.cloudmile.com/peers/peer0.org1.cloudmile.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

Success

### Peers

VM-1
```
root@fabric-dev-peer-1:~/a-fabric# peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
[{"AppraisedValue":300,"Color":"blue","ID":"asset1","Owner":"Tomoko","Size":5,"docType":"asset"},{"AppraisedValue":400,"Color":"red","ID":"asset2","Owner":"Brad","Size":5,"docType":"asset"},{"AppraisedValue":500,"Color":"green","ID":"asset3","Owner":"Jin Soo","Size":10,"docType":"asset"},{"AppraisedValue":600,"Color":"yellow","ID":"asset4","Owner":"Max","Size":10,"docType":"asset"},{"AppraisedValue":700,"Color":"black","ID":"asset5","Owner":"Adriana","Size":15,"docType":"asset"},{"AppraisedValue":800,"Color":"white","ID":"asset6","Owner":"Michel","Size":15,"docType":"asset"}]
```
VM-2
```
root@fabric-dev-peer-2:~/a-fabric# peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
[{"AppraisedValue":300,"Color":"blue","ID":"asset1","Owner":"Tomoko","Size":5,"docType":"asset"},{"AppraisedValue":400,"Color":"red","ID":"asset2","Owner":"Brad","Size":5,"docType":"asset"},{"AppraisedValue":500,"Color":"green","ID":"asset3","Owner":"Jin Soo","Size":10,"docType":"asset"},{"AppraisedValue":600,"Color":"yellow","ID":"asset4","Owner":"Max","Size":10,"docType":"asset"},{"AppraisedValue":700,"Color":"black","ID":"asset5","Owner":"Adriana","Size":15,"docType":"asset"},{"AppraisedValue":800,"Color":"white","ID":"asset6","Owner":"Michel","Size":15,"docType":"asset"}]
```

-----


## On GKE

```
kubectl exec peer0-org1-cloudmile-com-0 -c peer0-org1 -it  sh
```

 
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
1.
```
 Bad configuration detected: Received AliveMessage from a peer with the same PKI-ID as myself: tag:EMPTY alive_msg:
```
You are using the same certificate for two different peers and it is forbidden
2.
```
Error: proposal failed (err: bad proposal response 500: access denied for [JoinChain][mychannel]: [Failed verifying that proposal's creator satisfies local MSP principal during channelless check policy with policy [Admins]: [The identity is not an admin under this MSP [Org1MSP]: The identity does not contain OU [ADMIN], MSP: [Org1MSP]]])
```
MSP is not addressed.
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/organizations/peerOrganizations/org1.cloudmile.com/users/Admin@org1.cloudmile.com/msp

```
Error: timed out waiting for txid on all peers
```

```
rror: failed to retrieve endorser client for approveformyorg: endorser client failed to connect to peer0.org1.cloudmile.com:30751: failed to create new connection: context deadline exceeded
```












