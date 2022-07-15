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

#### Background
Two peers in same org.

----
Facing What Error now? 2022/07/15

```
Failed obtaining connection for peer0.org1.cloudmile.com:7051, PKIid:ab65a72330b964ef2c1555e83eb48cd86e9a06f6ec60a44e626ebc1d7016408d reason: context deadline exceeded

```












