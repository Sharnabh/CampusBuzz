# Software Requirements Specification (SRS)

## Project Title: CampusBuzz

**Platform:** iOS
**Tech Stack:** SwiftUI, CometChat SDK, Firebase
**Purpose:** A real-time community app for college students to chat, collaborate, and stay updated.

---

## 1. Introduction

### 1.1 Purpose

The purpose of CampusBuzz is to provide a centralized communication platform for college students where they can interact in real time with classmates, faculty, and interest groups.

### 1.2 Scope

The app facilitates:

* Real-time group and private chats
* Course/semester-based discussion channels
* Club and interest group management
* Notifications and events
* User profiles and campus verification

### 1.3 Definitions

* **CometChat:** A communication SDK for integrating messaging, voice, and video features.
* **MAU:** Monthly Active Users
* **MVP:** Minimum Viable Product

---

## 2. Overall Description

### 2.1 Product Perspective

CampusBuzz is a mobile application leveraging CometChat's capabilities for real-time messaging and Firebase for backend support.

### 2.2 User Characteristics

* College students
* College faculty (admin rights optional)

### 2.3 Assumptions & Dependencies

* Internet connection is required
* CometChat SDK is used for all chat-related functions
* Firebase handles authentication and cloud storage

---

## 3. Functional Requirements

### 3.1 User Authentication

* Email/Apple login and optional anonymous access
* Firebase Authentication integration

### 3.2 Profile Setup

* Name, year, major, profile photo upload
* Store in Firestore with user UID as key

### 3.3 Group Chat

* Join semester/class-based groups
* Join open interest groups
* View members, share files, reactions, mentions

### 3.4 1-on-1 Chat

* Private messaging between users
* Block/report feature

### 3.5 Explore Groups

* List and search all available groups
* Join public groups

### 3.6 Event Notifications (Optional in MVP)

* Admin can post events to group chats
* Push notifications sent via Firebase

### 3.7 Moderation

* CometChat AI moderation for profanity and spam

---

## 4. Non-functional Requirements

* **Performance:** Real-time chat experience with < 200ms latency
* **Scalability:** Support up to 1,000 concurrent users in MVP
* **Reliability:** 99.9% uptime, fallback to Firebase cache on SDK failure
* **Security:** CometChat and Firebase secure data storage and access
* **Compliance:** GDPR-compliant user data handling

---

## 5. UI Design & Screens

### 5.1 Splash Screen

* App logo and tagline animation

### 5.2 Onboarding Slides

* Feature highlights (swipeable views)

### 5.3 Login/Register Screen

* Apple login
* Email login
* Continue as Guest

### 5.4 Profile Setup Screen

* Input fields: name, course, year
* Image picker for profile photo

### 5.5 Home Screen (Tab View)

* Tabs: Chat Feed, Groups, Explore, Profile

### 5.6 Chat Feed

* Display recent messages from all groups
* Quick reply inline

### 5.7 Group Chat Screen

* Chat interface (CometChat UI)
* Header with group info
* Message input, attachments, emojis, reactions

### 5.8 1-on-1 Chat Screen

* Similar to group chat but private

### 5.9 Explore Groups Screen

* List of public groups
* Join button

### 5.10 Profile Screen

* Profile details
* Edit option
* Logout button

### 5.11 Event Feed (Optional)

* List of events with date/time and RSVP

---

## 6. External Interface Requirements

### 6.1 Software Interfaces

* CometChat iOS SDK (v3)
* Firebase Authentication
* Firebase Firestore and Cloud Functions
* Firebase Storage for media files

### 6.2 Hardware Interfaces

* iOS device running iOS 15+

---

## 7. Future Enhancements

* Video calls and voice rooms
* AI-powered academic bot
* Anonymous confession boards
* Admin dashboard for event management

---

## 8. Appendix

* [CometChat Docs](https://www.cometchat.com/docs/ios/v3/)
* [Firebase Docs](https://firebase.google.com/docs/)

---

**End of SRS Document**
