
## 💬 Chats Screen (UIKit + CometChat UI Kit)

### 🎯 Objective:

This screen is the **hub for all conversations** — both 1-on-1 and group chats. It uses CometChat’s built-in `CometChatConversationsWithMessages` or `CometChatConversationList` + `CometChatMessages`.

---

## 🧱 Core Structure

### ✅ 1. **Navigation Bar**

* **Title**: `"Chats"`
* **Left Item**: Profile avatar or app logo
* **Right Items**:

  * 🔍 Search icon (filters user/group)
  * ➕ New Chat button (start DM or create group)

```swift
self.title = "Chats"
navigationItem.rightBarButtonItems = [
    UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newChatTapped)),
    UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
]
```

---

### ✅ 2. **Conversation List**

**Component**: `CometChatConversationList()`

**Features:**

* Displays recent 1-on-1 & group conversations
* Profile pictures + last message snippet
* Unread message count badge
* Typing indicator
* Online/offline status for users
* Supports swipe to delete or mute

**Customization Tip:**

```swift
let conversationList = CometChatConversationList()
conversationList.set(conversationType: .none) // All conversations
conversationList.delegate = self
```

✅ You can filter to only groups:

```swift
conversationList.set(conversationType: .group)
```

---

### ✅ 3. **Empty State**

If no conversations:

* Message: `"No conversations yet."`
* CTA: `"Join a group"` → redirects to Explore tab

---

### ✅ 4. **Tapping a Conversation**

Tapping a conversation item opens the **message screen**:

```swift
let messagesVC = CometChatMessages()
messagesVC.set(conversationWith: userOrGroup, type: .user or .group, name: displayName)
self.navigationController?.pushViewController(messagesVC, animated: true)
```

---

## 🎨 UI Details

| Element          | Style Example              |
| ---------------- | -------------------------- |
| Row height       | 72pt                       |
| Font (Name)      | SF Pro Semibold (16pt)     |
| Message preview  | SF Pro Regular (14pt) gray |
| Unread badge     | Red with white number      |
| Typing indicator | “Typing…” in italic gray   |
| Avatar           | Circular, 40–44pt          |

✅ Use `CometChatUIKit.bundle` to customize colors/fonts/images if needed.

---

## 🔍 Optional Additions

### 🔘 Segment Control (Top)

Switch between:

* All
* Groups
* Direct Messages

### 🔄 Pull-to-Refresh

Refresh conversation list using:

```swift
conversationList.refresh()
```

### 🔔 Mute/Block Options

Swipe left → Mute, Block

### 💬 Quick Actions

* Long press → Pin conversation
* Right swipe → “Mark as unread”

---

## 📱 iPhone UI Wireframe (Top to Bottom)

```
+--------------------------------------------------+
| Chats          [🔍]     [➕]                       |
+--------------------------------------------------+
| [Profile Picture]  John (Online)                >|
|                 Hey, what’s the update? [3]      |
+--------------------------------------------------+
| [Group Icon]     CSE Sem 5                      >|
|                 Notes uploaded!       [1]        |
+--------------------------------------------------+
| Empty State:                                     |
|  "No chats yet. Join a group to start chatting." |
|       [Join a Group]                             |
+--------------------------------------------------+
```

---

## 🧩 Integration Code Snippet

```swift
class ChatsViewController: UIViewController {
    
    let conversationList = CometChatConversationList()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chats"
        setupNavigation()
        setupConversationList()
    }

    func setupNavigation() {
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(startNewChat)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        ]
    }

    func setupConversationList() {
        conversationList.delegate = self
        conversationList.frame = self.view.bounds
        self.view.addSubview(conversationList)
    }

    @objc func startNewChat() {
        // Show user/group list
    }

    @objc func search() {
        // Push to search controller
    }
}
```

---

## 🧠 UX Notes

* Conversations are sorted by `lastMessage.timestamp DESC`
* Add subtle haptic feedback when tapping
* Support dark mode with proper color overrides in the UI Kit bundle