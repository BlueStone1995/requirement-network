## Running the test network

You can use the `./network.sh` script to stand up a simple Fabric test network. The test network has two peer organizations with one peer each and a single node raft ordering service. You can also use the `./network.sh` script to create channels and deploy the fabcar chaincode. For more information, see [Using the Fabric test network](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html). The test network is being introduced in Fabric v2.0 as the long term replacement for the `first-network` sample.

Before you can deploy the test network, you need to follow the instructions to [Install the Samples, Binaries and Docker Images](https://hyperledger-fabric.readthedocs.io/en/latest/install.html) in the Hyperledger Fabric documentation.

Script bash:
```bash
# Stand up the network with certificate authority
./network.sh up -ca
# Create channel
./network.sh createChannel
# Deploy go chaincode
./network.sh deployCC
# Interact with network
./network.sh invokeCC

#Access to docker chaincode
sudo docker exec -it dev-peer0.org1.requirementnet.com-requirement /bin/sh

# Stopping network
./network.sh down
```