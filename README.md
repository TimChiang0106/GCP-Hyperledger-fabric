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
 apt-get install docker.io
 apt-get install docker-compose
 ```

or another way to install docker-compose
```
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
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
5. Set the env var
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

6. Run the code
   1. Bring up the test network
   2. Creating a channel
   3. Starting a chaincode on the channel

```
./network.sh down
./network.sh up
./network.sh createChannel
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript/ -ccl javascript
```


7. Initialize the ledger with assets. 
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```
8. Query the ledger
```
 peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

-----


## Create your own blockchain network.

1. Edit /etc/hosts -> Insert your vm ip address
2. cryptogen 
3. docker-compose -f path up -d, Create compose.yaml, please see the [template](https://github.com/TimChiang0106/hyperledger-fabric-gcp-vm/tree/master/tim-network/compose/compose-tim-network.yaml)
4. 
5. 










