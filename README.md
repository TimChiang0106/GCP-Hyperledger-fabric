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

b. To pull the Docker containers and clone the samples repo, run one of these commands for example
```
./install-fabric.sh docker samples
./install-fabric.sh d s
```
c. Install fabric
```
./install-fabric.sh 
```
