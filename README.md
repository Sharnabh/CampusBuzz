# CampusBuzz 🎓

A modern iOS messaging application for campus communities, built with Swift, Firebase, and CometChat. CampusBuzz enables students to connect through group chats, direct messaging, and campus-wide discussions.

## 📱 Features

- **Authentication**: Email-based sign up/sign in with Firebase Auth
- **Real-time Messaging**: Powered by CometChat SDK for instant messaging
- **Group Chats**: Join semester/class-based groups and interest-based communities  
- **Direct Messages**: Private 1-on-1 conversations between users
- **User Profiles**: Customizable profiles with photo upload and course information
- **Group Discovery**: Explore and join public campus groups

## 🛠 Tech Stack

- **iOS**: Swift 5.0+, UIKit
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Messaging**: CometChat SDK v5.0.4
- **Dependency Management**: CocoaPods
- **Minimum iOS Version**: 15.0+

## 📋 Prerequisites

Before running this project, ensure you have:

### Development Environment
- **Xcode 14.0+** (with iOS 15.0+ SDK)
- **macOS 12.0+** (Monterey or later)
- **CocoaPods 1.11+** installed
- **Git** for version control

### Third-Party Services Setup

#### 1. Firebase Configuration
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
- Enable the following services:
  - **Authentication** (Email/Password provider)
  - **Cloud Firestore** (Database)
  - **Cloud Storage** (File uploads)
- Download `GoogleService-Info.plist` and add to your project
- Configure Firebase Security Rules for Firestore and Storage

#### 2. CometChat Configuration  
- Create an account at [CometChat Dashboard](https://app.cometchat.com)
- Create a new app and note down:
  - **App ID**: `277721deb05dda5c`
  - **Region**: `IN` (India)
  - **Auth Key**: `d4df456ef23f05f772fbde89982edd1dd1f4d6f6`

> **Note**: The above credentials are for demo purposes. Replace with your own production credentials.

### Hardware Requirements
- **Mac with Apple Silicon (M1/M2)** or **Intel-based Mac**
- **Minimum 8GB RAM** (16GB recommended for optimal performance)
- **10GB free disk space** for Xcode, dependencies, and project files

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/CampusBuzz.git
cd CampusBuzz
```

### 2. Install Dependencies
```bash
# Install CocoaPods if not already installed
sudo gem install cocoapods

# Install project dependencies
pod install --repo-update
```

### 3. Configure Firebase
1. Place your `GoogleService-Info.plist` file in the `CampusBuzz/` directory
2. Ensure the file is added to the Xcode project target

### 4. Configure CometChat
Update the credentials in `CampusBuzz/General/CometChatConfig.swift`:
```swift
static let appID = "YOUR_COMETCHAT_APP_ID"
static let region = "YOUR_REGION" 
static let authKey = "YOUR_AUTH_KEY"
```

### 5. Open and Build
```bash
# Open the workspace (NOT the .xcodeproj file)
open CampusBuzz.xcworkspace
```

1. Select your development team in Project Settings
2. Choose a simulator or connected device
3. Build and run (`Cmd + R`)

## 📁 Project Structure

```
CampusBuzz/
├── CampusBuzz/
│   ├── General/                 # Core app files
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   ├── AuthViewController.swift
│   │   ├── CometChatConfig.swift
│   │   ├── CometChatManager.swift
│   │   └── FirebaseManager.swift
│   ├── Models/                  # Data models
│   │   └── HomeModels.swift
│   ├── Tabs/                    # Main app tabs
│   │   ├── Chats/              # Chat-related screens
│   │   ├── Explore/            # Group discovery
│   │   ├── Home/               # Home feed
│   │   └── Profile/            # User profile
│   ├── Storyboards/            # UI storyboards
│   └── View Models/            # MVVM architecture
├── Pods/                       # CocoaPods dependencies
├── Podfile                     # Dependency configuration
└── GoogleService-Info.plist   # Firebase configuration
```

## 🎯 Core Components

### Authentication Flow
- **Entry Point**: `AuthViewController.swift`
- **Firebase Auth**: Handle email/password authentication
- **CometChat Integration**: Automatic user creation and login
- **Session Management**: Persistent login state

### Chat System
- **CometChat SDK**: Real-time messaging infrastructure
- **Group Management**: Campus-specific group creation and joining
- **Message Types**: Text, media, files with size validation
- **UI Components**: Custom chat interfaces built on CometChatUIKit

### User Management
- **Profile System**: Firestore-based user profiles
- **Image Upload**: Firebase Storage integration

## 🐛 Common Issues & Solutions

### 1. Build Errors & Pod Installation Issues

#### Problem: `Pod install` fails with dependency conflicts
```
[!] CocoaPods could not find compatible versions for pod "Firebase/Core"
```

**Solution**:
```bash
# Clear CocoaPods cache and reinstall
pod cache clean --all
pod deintegrate
pod install --repo-update --verbose
```

#### Problem: `The iOS Simulator deployment target is set to 8.0, but the range of supported deployment target versions is 11.0 to 16.4.0`

**Solution**: Our Podfile includes a post-install script that fixes this:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

### 2. Firebase Configuration Issues

#### Problem: `GoogleService-Info.plist` not found
```
*** Terminating app due to uncaught exception 'com.firebase.core'
```

**Solutions**:
1. Ensure `GoogleService-Info.plist` is in the project root and added to target
2. Check Bundle ID matches Firebase project configuration
3. Verify the file is not corrupted or empty

#### Problem: Firebase Storage permission denied
```
ERROR: Permission denied. Could not perform this operation
```

**Solution**: Update Firestore Security Rules:
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Add other collection rules as needed
  }
}

// Storage Rules  
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}.jpg {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. CometChat Integration Issues

#### Problem: CometChat initialization fails
```
CometChat initialization failed with error: Invalid App ID
```

**Solutions**:
1. Verify App ID, Region, and Auth Key in `CometChatConfig.swift`
2. Ensure CometChat app is active in dashboard
3. Check internet connectivity for initial setup

#### Problem: User creation fails with "User already exists"
```
CometChatManagerError.userCreationFailed("User with UID already exists")
```

**Solution**: This is handled in our `SceneDelegate.swift`:
```swift
// Try login first, create user only if login fails
CometChatManager.shared.loginUser(uid: uid) { result in
    switch result {
    case .success:
        // User exists, proceed
    case .failure:
        // User doesn't exist, create new user
        self.createCometChatUser()
    }
}
```

#### Problem: Message sending fails
```
Failed to send message: Network request failed
```

**Solutions**:
1. Check network connectivity
2. Verify user is logged into CometChat
3. Ensure receiver exists and is valid
4. Check CometChat service status

### 4. Xcode & Simulator Issues

#### Problem: Simulator won't launch or crashes
**Solutions**:
1. Reset simulator: `Device → Erase All Content and Settings`
2. Restart Xcode and clean build folder (`Cmd + Shift + K`)
3. Delete derived data: `~/Library/Developer/Xcode/DerivedData`

#### Problem: "Could not launch" error on device
**Solutions**:
1. Check provisioning profile and code signing
2. Ensure device is trusted in Settings
3. Verify Bundle ID is unique and registered

### 5. Runtime Issues

#### Problem: App crashes on startup
**Common Causes & Solutions**:
1. **Missing Firebase config**: Add `GoogleService-Info.plist`
2. **Invalid CometChat credentials**: Update `CometChatConfig.swift`
3. **iOS version compatibility**: Ensure device runs iOS 15.0+

#### Problem: Images won't upload or load
**Solutions**:
1. Check Firebase Storage rules allow authenticated uploads
2. Verify image format and size limits (we validate in code)
3. Ensure proper error handling for network issues

#### Problem: Push notifications not working
**Solutions**:
1. Enable Push Notifications capability in Xcode
2. Configure APNs certificates in Firebase Console
3. Request notification permissions in app

## 🔧 Development Tips

### Testing
- Use iOS Simulator for UI testing
- Test on multiple device sizes (iPhone SE, iPhone 14 Pro Max)
- Test with poor network conditions
- Verify offline behavior and data persistence

### Debugging
- Enable Firebase Debug logging: Add `-FIRDebugEnabled` launch argument
- Use CometChat debug logs for messaging issues
- Monitor network requests in Xcode Network Instruments

### Performance
- Optimize image loading with caching
- Implement pagination for large chat lists
- Use background queues for Firebase operations
- Monitor memory usage with Xcode Instruments

## 📝 Firebase Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isGroupMember(groupId);
    }
    
    function isGroupMember(groupId) {
      return request.auth.uid in resource.data.members;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}.{extension} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /chat_media/{chatId}/{fileName} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🚀 Deployment

### TestFlight Distribution
1. Archive the app (`Product → Archive`)
2. Upload to App Store Connect
3. Add beta testers in TestFlight
4. Distribute for testing

### App Store Submission
1. Ensure all Firebase and CometChat credentials are production-ready
2. Update app version and build number
3. Add app metadata and screenshots
4. Submit for review following [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## 📋 Environment Configuration

### Development
- Use Firebase project in test mode
- Enable debug logging
- Use CometChat sandbox environment

### Production
- Switch to production Firebase project
- Disable debug logging
- Use production CometChat credentials
- Enable crash reporting and analytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **CometChat Documentation**: [docs.cometchat.com](https://docs.cometchat.com)
- **Firebase Documentation**: [firebase.google.com/docs](https://firebase.google.com/docs)
- **iOS Development**: [developer.apple.com](https://developer.apple.com)

## 🔗 Related Resources

- [CometChat UIKit Swift](https://github.com/cometchat/cometchat-uikit-swift)
- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Built with ❤️ for campus communities**

*CampusBuzz v1.0.0 - Connecting students, one chat at a time.*
