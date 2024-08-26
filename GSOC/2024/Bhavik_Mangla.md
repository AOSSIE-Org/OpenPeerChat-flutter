## **GSOC AOSSIE 2024**

## _OpenPeerChat - Peer to Peer Messaging App_

## Project Description
The OpenPeerChat app is a secure, peer-to-peer messaging platform designed to prioritize user privacy and data protection. Built using Flutter, it enables users to communicate and share files directly with one another without relying on centralized servers. The application will be hugely beneficial in disaster-prone areas or remote areas where the cellular connections are too weak to communicate through general messaging applications. The app emphasizes robust encryption, secure authentication methods and offer a seamless and user-friendly messaging experience making it an ideal choice for those who value confidentiality in their digital communications.

## Chosen Idea:
- Implementation of RSA in messages.
- Enabling Sending files, images, audio and video.
- Make the UI suitable to view those files sent.
- Update dependencies.

## **Updates:**
### User Authentication:
- Added a password lock and a fingerprint lock for on-device authentication of the user using the `local_auth` package.
- Ensured secure and seamless authentication methods to enhance user security.

### Dependencies and Testing:
- Updated all dependencies and packages to the latest versions.
- Set the version and build number, and upgraded to the latest Kotlin version in `build.gradle`.
- Tested the app's functionality across multiple devices and platforms to ensure compatibility and stability.

### RSA Encryption:
- Implemented Public and Private Key Generation for secure communications.
- Integrated RSA Encryption, and developed methods for encoding and parsing public/private keys to and from PEM format using libraries such as `asn1lib`, `dart:typed_data`, `dart:convert`, and `pointycastle`.
- Stored primary and public keys securely using `flutter_secure_storage`, `sqflite`, and `flutter_nearby_connections`.
- Shared encrypted public keys between users upon establishing a connection to ensure secure communication.
- Implemented the storage and transmission of encrypted messages in global cache and sqflite tables, decrypting them with the user's private key.
- Added RSA encryption specifically for file sharing to further enhance security.

### Chat Functionality:
- Improved the Chat Page UI by adding dates and chat bubbles to make it visually similar to WhatsApp chats. (`bubble`)
- Developed a separate, clean UI for file viewing within the chat interface.

### File Handling:
- Completed the implementation of file viewing, which supports all file types.
- Implemented secure file sharing and storing on device between users, ensuring that files are encrypted during transmission. (`file_picker`, `open_filex`, `permission_handler`, `path_provider`)
- Set a maximum limit for file sizes to ensure quick and efficient file transfers.

### Additional Enhancements:
- Added a powerful search feature on the home screen, enabling users to quickly find and connect with others in All Chats and Devices pages.
- Enhanced the overall user experience by refining the UI and addressing visual bugs.
- Engaged in regular code reviews and optimizations to maintain code quality and performance.


## App Flow:

- User Authentication:
  Upon opening the app, users are prompted to authenticate using a password or fingerprint, ensuring secure access.

- New User Setup:
  New users are prompted to enter their name after successful authentication, establishing their identity within the app.

- Home Screen:
  After setup, users are taken to the home screen, which features a search bar to quickly find and connect with other users or devices.

- Chat Interface:
  The chat page displays conversations with dates and chat bubbles, offering a familiar and intuitive experience similar to WhatsApp.

- File Viewing and Sharing:
  Users can view and share files securely within the chat interface. File transfers are encrypted using RSA encryption, with a maximum file size limit to ensure efficiency.

- Secure Communication:
  RSA-encrypted messages are stored and transmitted securely, with public keys shared between users upon connection.

## **Future Work:**
- Develop a robust notification system to alert users about new messages, file transfers, and other critical updates, ensuring timely and reliable communication.
- Add an upload progress indicator for larger file transfers, visible on both sender and receiver screens, to improve user experience during file sharing.
- Ensure that changes to a user's profile name are reflected in nearby devices, maintaining consistency in chat history and user identification.
- Verify and enhance cross-platform compatibility, ensuring seamless communication and functionality between Android and iOS devices, fostering a unified user experience across different platforms.
- Prepare for publishing the app on the Google Play Store and Apple App Store, including meeting all necessary guidelines and requirements for app submission.


## Demonstration Links
- Video: [OpenPeerChat GSOC 2024](https://drive.google.com/file/d/1cSx_MPT7jJ-pKTPfi6foHkJKkLGvqt3h/view?usp=sharing)
- APK: [OpenPeerChat App](https://drive.google.com/file/d/1Nlz8oKXRIaQC5KVznvr2fus-8CM9JZlv/view?usp=sharing)


## Merge Requests
https://github.com/AOSSIE-Org/OpenPeerChat-flutter/pull/21
https://github.com/AOSSIE-Org/OpenPeerChat-flutter/pull/23

## Contributor Details
- Name: Bhavik Mangla
- GitHub: [bhavik-mangla](https://github.com/bhavik-mangla)
- Email: bhavikmangla1234@gmail.com
- LinkedIn: [bhavikmangla](https://www.linkedin.com/in/bhavikmangla/)
- Organization: [Australian Open Source Software Innovation and Education (AOSSIE)](https://aossie.org/)
- Project: [Resonate - Open Source Social Voice Platform](https://github.com/AOSSIE-Org/Resonate)

## **Conclusion:**
The app has made tremendous strides in improving security, user experience, and overall functionality. By implementing advanced RSA encryption and secure authentication mechanisms, the foundation for safe and private communication has been firmly established. The chat interface has been refined with thoughtful enhancements, making conversations more visually appealing and easier to navigate. File handling capabilities have been expanded to support all file types, with secure sharing and storage features ensuring that user data is protected at every step.
Looking ahead, by introducing a notification system, refining the UI, and enhancing profile management, the app is poised to offer a robust, secure, and user-friendly environment. It will elevate the app’s performance and user customization options, ensuring it remains a secure and versatile tool for communication.