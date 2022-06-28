# Hyperledger Fabric Deployed on Google Cloud Compute Engine

Referring to Hyperledger Fabric  [doc](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html), I follow up all steps to create fabric in gce VM to running test network.

 


## Steps

1. Creat a Compute Engine VM with Ubuntu.

 a. Name: vm-fabric
 
 b. Region: asia-east1, Zone: asia-east1-a
 
 c. Series: E2, Machine type: e2-medium
 
 d. Boot disk, size: 20GB, Image: Ubuntu 18.04 TLS

Leave rest of setting with default.

2. SSH into VM.


 a. To get the install script.
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```
 b. Install Docker and Docker-compose
 ```
 sudo apt-get update
 apt-get install docker
 apt  install docker.io
 apt  install docker-compose
 ```
c. To pull the Docker containers and clone the samples repo, run one of these commands for example
 ```
 ./install-fabric.sh docker samples
 ./install-fabric.sh d s
 ```
c. Install fabric
```
./install-fabric.sh 
```


4. Into test-network
```
cd fabric-samples/test-network
```
5. Running code
```
./network.sh down
./network.sh up
./network.sh createChannel
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript/ -ccl javascript
```





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

```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```
```
 peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```






| # | node | IP & Port | hostname |
| ------ | ------ | ------ | ------ |
| 1 | Orderer | x.x.x.x:7050 | dev.alpha.orderer.com
| 2 | Orderer | x.x.x.x:8050 | dev.beta.orderer.com
| 3 | Orderer | x.x.x.x:9050 | dev.gamma.orderer.com
| 4 | Org | x.x.x.x:11051 | org1.com
| 4 | Org | x.x.x.x:12051 | org2.com

| # | Parameters | |
| ------ | ------ | ------|
|1| Channel| channel1
|2| Smart Contrace(chaincode)| dev-bsx-chaincode





