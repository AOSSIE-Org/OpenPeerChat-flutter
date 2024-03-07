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

## App Working Video
Here is the video for the working application.

https://drive.google.com/file/d/1Egv-RhbZmwLcs0yskrFm4Ym8IX44D1qg/view?usp=sharing

## APK Link
https://drive.google.com/file/d/1fBfJO6akTe_-GXhvtEcr_qd59W7Ah5YG/view?usp=sharing

## Project Link
https://gitlab.com/aossie/p2p-messaging-flutter

## GSOC 2022 Branch Link
https://gitlab.com/aossie/p2p-messaging-flutter/-/tree/gsoc-2022
