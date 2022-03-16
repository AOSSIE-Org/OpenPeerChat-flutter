

# Chosen Idea:
 A message sending/relaying messages to nearby devices until the destination is reached, instead of relying on a central server. GPS positioning could be used to route messages along the shortest path. Right now, despite the use of end-to-end encryption, our best and most popular messaging apps still rely on central servers to intermediate the communication. This has disadvantages such as:
* Authorities can censor the use of the messaging application by targeting the operator of the servers.
* The operator of the servers can know who is talking to whom, even if it can't know exactly what they are talking about.
* An internet connection is needed to communicate with the server.
* A messaging app that enables peer-to-peer communication would be a very interesting app where the issues above are relevant.
The app will provide extra resilience, censorship resistance and privacy is, of course, communication efficiency. Messages would be transmitted more slowly. And, if there is not a path of users geographically between two users A and B to relay the message, a message from A to B might never arrive.
Mentors: Bruno, Thuvarakan
 
# Proposal Description:
- Proposing to build a Chat app for Android and IOS in flutter/dart which sends messages Using Bluetooth & wifi-direct.
- Each device has a UUID to identify it and optionally the user's name.
- Each account is linked to a username(can be authenticated using OAuth)  and each message is directed to another username which is mapped to all devices logged in with that username.
- Users can choose to be anonymous as well.
- Using Bluetooth and wifi direct eliminates the use of a central server.
- The app scans for nearby devices which are discoverable and connects to them allowing messages to be relayed through each device(a node in a network)
- The messages will be transferred using an optimal path using underlying network protocols.
- Protocol to be used:  for hops, I used the gossip protocol, as it works even when devices are removed and added frequently.
	the way the protocol works is:
### The following have been implemented

- Discover nearby devices
- Connect to nearby devices
- Send messages to multiple devices
- Receive messages form mutliple devices
- Normal chat interface built
 - Designed the hop architecture (Push gossip protocol)
 - each message has a unique  ID
 - Each message should be transmitted to other nodes using the above described gossip protocol
     - For this Each device on the network must be able to “gossip”  and transmit the message to the destination
 - Offline storage of undelivered messages: 
 - If a ‘delivered’ callback is not received from the recipient the, the message is marked as undelivered, and its put in a local SQLite database(because SQLite has native support for android)
 the sender device will ping for the recipient in small regular intervals thereafter and if it finds the device ‘online’ on the network then it'll retry to send the message.
 Once the message has been delivered, it'll be marked as delivered.
 - RSA encryption is given support, i.e DB table for storing keys has been implemented. Minor intergration with UI is left but after which the user can upload public keys of their friends and the message will be encypted using that. Thus messages are end to end encypted

# App flow
- then the app is started, the user is asked to enter their name and a random string is added to their name, to make sure its unique
- After that the user is taken to the "available devices page" where all nearby devices are displayed and its auto connected to it. 
- In the bottom navigation bar, clicking the chats, will take you to your converstations which are backed up from local SQLite DB. You can create a new conversation using the floating button below. 
- On pressing on each chat name, the user is directed to chat page with lists all the chats which were fetched from DB.
- The user can send and receive messages here.

# Link to Merge Requests

- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/1
- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/10
- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/12
 
