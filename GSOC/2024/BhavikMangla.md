# Peer-to-Peer Messaging Application GSoC 2024

## Chosen Goals
1. Implement on-device user authentication for enhanced security.
2. Complete integration of RSA encryption to secure messaging.
3. Enable seamless sending and viewing of files, images, audio, and video.
4. Enhance the user interface to support intuitive file viewing.
5. Update project dependencies for improved performance and stability.

## Project Overview
The Peer-to-Peer messaging application aims to create a decentralized messaging platform, eliminating reliance on 
centralized servers vulnerable to privacy breaches. By leveraging device networking capabilities, the app ensures 
robust communication even in disaster-prone or remote areas with weak cellular connectivity.

## Detailed Progress and Achievements

### Security Enhancements
- **User Authentication:**
    - Implemented password and fingerprint locks for on-device user authentication using the `local_auth` package.
    - Ensured secure access to the app, enhancing user privacy and data protection.

- **RSA Encryption:**
    - Integrated RSA encryption for secure messaging between connected clients.
    - Utilized libraries like `rsa_encrypt`, `asn1lib`, `dart:typed_data`, `dart:convert`, and `pointycastle` for 
      key generation, encryption, and parsing.
    - Stored and transmitted public and private keys securely using `flutter_secure_storage` and `flutter_nearby_connections`.

### File Handling
- **File Sharing:**
    - Implemented secure file sharing functionality for sending files, images, audio, and video between users.
    - Ensured encryption of transmitted files to prevent unauthorized access.
    - Used `file_picker`, `open_file_x`, `permission_handler`, and `path_provider` for file operations.

- **File Viewing:**
    - Developed a user-friendly UI for in-app file previews and viewing.
    - Supported all file types for seamless user experience within the chat interface.

### UI Enhancements
- **Chat Interface:**
    - Enhanced the chat UI by adding date indicators and chat bubbles for a more intuitive messaging experience.
    - Created a clean and organized UI specifically for viewing shared files within the chat.

### Dependencies and Testing
- **Dependency Management:**
    - Updated all project dependencies and packages to their latest versions.
    - Ensured compatibility and stability across multiple devices and platforms through rigorous testing.

## Next Steps
- **Finalize RSA Encryption for Files:**
    - Complete the implementation of RSA encryption specifically for file sharing to bolster security.

- **UI Refinements:**
    - Continue refining the user interface based on user feedback to improve usability and aesthetics.

- **Testing and Validation:**
    - Conduct comprehensive testing to validate the app's security, performance, and user experience.

- **Prepare for App Publication:**
    - Prepare the app for publication on the Google Play Store and Apple App Store.
    - Ensure compliance with all guidelines and requirements for app submission.

## Conclusion
The progress achieved during GSoC 2024 has significantly enhanced the security, functionality, and user experience 
of the Peer-to-Peer messaging application. By implementing robust authentication mechanisms, advanced encryption techniques,
and seamless file sharing capabilities, the app is well-positioned to offer users a secure and reliable communication platform. 
Moving forward, the focus will be on finalizing remaining features, refining the UI, conducting thorough testing, and 
preparing for app publication to reach a broader audience.
