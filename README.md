# Peer-to-Peer Messaging Application
 
# LATEST Updates (GSOC 2024) - 
https://github.com/AOSSIE-Org/OpenPeerChat-flutter/blob/main/GSOC/2024/Bhavik_Mangla.md

# Contribution Guidelines - 
https://github.com/AOSSIE-Org/OpenPeerChat-flutter/blob/main/Contribution_Guidelines.md

GSoC pitch 2021.
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
- Protocol to be used:  for hops, I will be using the gossip protocol, as it works even when devices are removed and added frequently.
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
 - RSA encryption has been implemented. The user can upload public keys of their friends and the message will be encypted using that. Thus messages are end to end encypted
 
 
 
# Gossip Protocol
 
- Multicast sender
## Push gossip protocol
 
 - When a node receives a message or gossip, it periodically passes it on to other nodes, and that node is said to be infected
 -  all infected nodes periodically multicast to other nodes
    
## Pull gossip protocol
 
 - Periodically poll a few randomly selected processes for new multicast messages that you haven't received and gets those messages
 - If there are multiple such messages, it polls a few of them randomly
## Hybrid variant
 - Mix of both push and pull types
 
`The push protocol is lightweight in large groups, spreads quickly and is highly fault-tolerant. Let us see why.`
 
## Analysis of the Gossip Protocol
 
Interestingly the analysis of the protocol is similar to the analysis of epidemic disease spread (cough cough covid) 
 
 
So,
- If we have a population of n+1 individuals mixing homogeneously
- If the contact rate between any individual pair is denoted to by B
- At any time, each individual is either uninfected (numbering x) or infected (numbering y),
- Then x+y is a constant equaling to n+1
- Intuitively, we can say that if an infected and uninfected node communicate, the latter obviously turns infected.
 
 
After solving a couple of differential equations, we get
 
- x=n(n+1)/(n+e^(B(n+1)t))  as t goes to infinity we can see this approaches 0, thus all of the nodes are infected. The next equation collaborates this.
- y=n(n+1)/(n+e^(-B(n+1)t))
 
 
 
- Taking B=b/n  we end up with y=(n+1)-1/(n^(cb-2)) in log(n) time.
 
Wow, that's pretty fast, right?
 
 
That explains why COVID spread so quickly!  
 
 
## Analysis of pull protocol
 
- As a fact, all gossip protocols take O(log n) rounds before half of them get to gossip.
 - This is because it’s the fastest way to send a message. Construct a spanning tree with a constant degree of every node is O(log n).
 - Once this point is achieved, we find that the pull protocol is faster than the push protocol.
- Let p(i) be the fraction of non-infected processes, after ith round, then
 
    p(i+1)=(p(i))^(k+1)
- This is super-exponential.
 - Thus the second half of the gossip protocol finishes in O(log(log n))
 
 
`Mixing pull and push in both halves gives rise to a hybrid version.`
 
 
- The messages need to be compressed 
- The message can be broken into many pieces during transmission and rebuilt at the destination. This helps in maintaining security as each node will never have the complete message
- If the receiver is not online in the network then the sender’s device must have the ability to store it and ping the receiver in regular intervals and when it finds it online again, it should resend the message. 
- such unsent messages will be stored in a local database
- Use Case of such a p2p system: complete disruption of internet and phone services in case of natural disasters.
## Implementation
There are 6 main parts the above idea can be broken into,
- Build a android/IOS app that can,
- Discover nearby devices
- Connect to nearby devices
- Send messages to multiple devices
- Have a Normal chat interface
- use the 'hopping message' architecture to relay messages
- offline storage of undelivered messages
 
# Peer to Peer Messaging application GSOC 2022

## Choosen Idea
1) Change the project Push Gossip Protocol to either Pull Protocol or Hybrid protocol
2) Updating the User Interface for the Application.

## Project Description
The Peer to Peer messaging application aims to build an application that does not rely on a central server governed by laws and influenced by third party users. Currently, we are relying on applications that are based on central server messaging that can use our private data for their benefit regardless of the privacy policies without knowing the user. We came across incidents of data breaches where the personal data of a large number of users was disclosed to hackers. Hence a solution would be to move the data from the central server to a distributed network. The distributed network will be able to provide better privacy, less dependence on the network, and freedom from central network laws.
The application will be hugely beneficial in disaster-prone areas or remote areas where the cellular connections are too weak to communicate through general messaging applications. In this case, this application would communicate through device networking capabilities. Hence the app is reliable and the project is working for a good cause. Hence I am motivated to develop and contribute to this project. 

## Proposal Detailed Approach
I intend to propose an approach to transfer the messaging protocol of the application from the naive push protocol. The push protocol has many disadvantages and so we need to migrate to either pull protocol or hybrid protocol. The hybrid model that is used in this project is the First-Push-Then-Pull protocol.

### Hybrid Protocol Implementation
Hybrid protocol comprises both the Push protocol and Pull protocol. The approach for this protocol is First Push and then Pull. It works on the following principle.
- As we know, the push protocol has better performance in the initial rounds. So we first take the use of the push protocol and propagate the message until some rounds.
- Next, we will apply the pull protocol where the devices will start asking for updates.
- In this way, we will achieve the propagation time of O(log(log N)), which is much better than O(log N) for the push protocol.

**Determination of transition period**We cannot change from push protocol to pull protocol randomly. We need a definite round where the nodes will change from push to pull protocol. 
1) First the Pull protocol works as it asks the connected devices that if there is new message with the help of method UPDATE that is being implemented.
2) The pull protocol continues until the application is on.
3) Now when a new message is being sent from a device, it pushes to the connected devices. The rest of devices receive the message with the help of Pull Protocol.
4) In this way, we achieve First Push and Then Pull protocol.

## Implementations in GSoC 2022
- The app previously required to enter the name every time the app launches. 
Now the application saves the user name and unique id(automatically generated) into the Shared Preferences that is being removed only when the app is installed. It is a key-value form of data storing way. So when the app is launched again, the app directly opens the Home Page.
- Home Page - It contains two tabs. The tabs are created and managed by default tab controller of the Flutter. 
    - Tab 1: Contains List of Connected and Disconnected but in network devices.
    - Tab2: List of devices conversed with previously.
- Provider State Management - Previously when viewing the chat page, if new message arrived from the person whom with we are chatting, the message was saved in Database but not displayed until relaunching the ChatPage. Hence the state management was required which ensured that when a new message arrived, it will be displayed instantly. This also improved the overall speed of the application as common details where available globally rather being transferring from one screen to other.
- Hybrid Protocol as discussed previously - First Push Then Pull (FPTP) Protocol.
- Updated the UI

## App Flow 
- ***(If first launched)*** - The app asks for the username and a random string is added to their name, to make sure its unique.
- Then the user is taken to the HomePage.
- One first tab, it contains the devices with whom he/she can connect with and chat.
- On second tab, it contains the devices with which devices it has chatted previously.
- On clicking any device name from the list, it can chat with the devices in realtime or if there is no connection, it is delivered when the app comes on network.

## Merge Requests
- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/18
- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/19
- https://gitlab.com/aossie/p2p-messaging-flutter/-/merge_requests/20
