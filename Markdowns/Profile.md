## 🙍‍♂️ Profile Screen — Full Layout & Functionality

---

### 🎯 Objective

Allow users to:

* View and update their profile info
* See joined groups
* Access app settings
* Log out or manage sessions
* View app version and report issues

---

## 🧱 Profile Screen: Top-to-Bottom UI Layout

### ✅ 1. **Navigation Bar**

* **Title**: `Profile`
* **Right Item (Edit)**: ✏️ icon to enable editing

```swift
self.title = "Profile"
self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
```

---

### ✅ 2. **User Info Card**

#### Contains:

* **Profile Picture** (Circle – 80pt x 80pt)
* **Full Name** (Bold, 20pt)
* **Course & Year** (e.g., “B.Tech CSE, 3rd Year”)
* **College ID** (optional badge-style label)
* **Online Status** indicator

**Interaction**: Tap profile picture to change it (image picker).

```swift
let profileImageView = UIImageView()
profileImageView.layer.cornerRadius = 40
profileImageView.contentMode = .scaleAspectFill
```

---

### ✅ 3. **Edit Profile Modal (Triggered by ✏️)**

Form fields:

* Full Name
* Course (dropdown or text)
* Year (dropdown)
* Change Profile Image

🔘 Save → Updates Firebase + CometChat user metadata.

---

### ✅ 4. **Joined Groups List**

#### Section Title: `"Your Communities"`

Displays horizontally scrollable chips/cards:

* Each card shows group name + small icon
* Tapping opens that group in chat screen

> Powered by `CometChat.getJoinedGroups()` or cached Firestore list.

---

### ✅ 5. **Account & Settings**

List-style table view with rows:

| Icon | Title                 | Action                          |
| ---- | --------------------- | ------------------------------- |
| 👤   | View My UID           | Shows UID in copyable text      |
| 🔔   | Notification Settings | Redirect to system settings     |
| ⚙️   | App Settings          | Dark mode toggle (or under dev) |
| 🧼   | Clear Cache           | Clears CometChat cache          |
| 🧾   | Privacy Policy        | Opens external link             |

---

### ✅ 6. **Feedback & Help**

* **Report a Problem** → In-app form or email
* **Rate This App** → Redirect to App Store
* **Version**: Displayed at bottom (e.g., “v1.0.0 (Build 5)”)

---

### ✅ 7. **Log Out Button**

* Positioned at bottom in red
* Action: Sign out of Firebase + CometChat
* Redirect to Login screen

```swift
CometChat.logout(onSuccess: {
    // Redirect to login
}, onError: { error in
    print("Logout failed: \(error?.errorDescription ?? \"\")")
})
```

---

## 🎨 UI Design Details

| Element         | Style                                  |
| --------------- | -------------------------------------- |
| Avatar          | Circle with border + shadow            |
| Fonts           | SF Pro, semi-bold titles, regular body |
| Colors          | Blue accents, light/white cards        |
| Buttons         | Rounded corners, filled                |
| Section headers | Uppercased, greyed-out                 |
| UX Interaction  | Haptic feedback on tap                 |

---

## 📱 iPhone UI Wireframe (Top to Bottom)

```
+-------------------------------------------+
|              Profile (Title)             ✏️|
+-------------------------------------------+
|  [Profile Pic]  John Doe                  |
|                B.Tech CSE, 3rd Year       |
|                ID: 21CSE102               |
+-------------------------------------------+
| Your Communities >                        |
|  [CSE Sem 5]  [Gaming Club]  [DSA Squad]  |
+-------------------------------------------+
| 🔔 Notification Settings                  |
| ⚙️ App Settings                           |
| 🧼 Clear Chat Cache                       |
| 🧾 Privacy Policy                         |
| 📤 Report a Bug                           |
+-------------------------------------------+
| 🔴 Log Out                                |
|           v1.0.0 (Build 5)                |
+-------------------------------------------+
```

---

## 🧠 UX Goals

* Minimal clicks to change details
* Immediate visual feedback
* Profile info is *always visible* at the top
* Respect platform UX patterns (native feel)

---

## 🧩 Backend Considerations

| Field              | Stored In            | Notes                   |
| ------------------ | -------------------- | ----------------------- |
| Name, Course, Year | Firebase Firestore   | User UID as document ID |
| Profile Image      | Firebase Storage     | URL cached in Firestore |
| Groups Joined      | CometChat            | `getJoinedGroups()`     |
| Metadata           | CometChat + Firebase | Sync with user metadata |

---

## ✅ Functionality Summary

| Feature            | SDK/API Used                         |
| ------------------ | ------------------------------------ |
| View Profile       | Firebase + UI                        |
| Edit Profile       | Form + Firestore update              |
| Joined Groups      | CometChat.getJoinedGroups()          |
| Logout             | CometChat.logout() + Firebase logout |
| Settings Links     | `UIApplication.shared.open(...)`     |
| Profile Pic Upload | UIImagePicker + Firebase Storage     |
