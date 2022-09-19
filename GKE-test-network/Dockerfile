FROM hyperledger/fabric-peer:2.4.4

LABEL  maintainer="Tim Chiang <tim.chiange@mile.cloud>"

COPY ./organizations/peerOrganizations/org1.cloudmile.com/peers/peer0.org1.cloudmile.com /etc/hyperledger/fabric

COPY ./organizations/peerOrganizations/org1.cloudmile.com/users /etc/hyperledger/users

RUN mkdir -p /etc/hyperledger/peercfg

COPY ./compose/docker/peercfg/core.yaml  /etc/hyperledger/peercfg

COPY ./bin /etc/hyperledger/bins

COPY ./chaincode /etc/hyperledger/nodechaincode

RUN  echo "cd /etc/hyperledger/bins" >> $HOME/.bashrc

CMD peer node start



