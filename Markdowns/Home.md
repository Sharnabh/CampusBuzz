Here’s a **deep-dive into the Home Screen UI** of **CampusBuzz**, structured with precision to deliver both functionality and engagement — your app’s heartbeat.

---

## 🏠 Home Screen: “CampusBuzz Central”

> A real-time overview of what’s happening in the campus — chats, events, and group activity.

---

### 🧱 Layout Overview (Top to Bottom)

#### ✅ 1. **Top Navigation Bar**

* **Title**: `CampusBuzz`
* **Left Item**: College logo or user profile avatar (tap to open ProfileView)
* **Right Items**:

  * 🔔 Notification bell (icon with badge)
  * 🔄 Refresh button (manual pull-to-refresh already preferred, but add optional)

**SwiftUI Tip**:

```swift
.navigationTitle("CampusBuzz")
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) { ProfileAvatarView() }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button(action: showNotifications) { Image(systemName: "bell.badge") }
        Button(action: refreshData) { Image(systemName: "arrow.clockwise") }
    }
}
```

---

#### ✅ 2. **Highlights Carousel (Optional)**

* Auto-scrolling banners showing:

  * 🔥 Trending Group
  * 📅 Upcoming Event
  * 🎉 Top Performing Club
* Tapable cards → deep link to chat or event

**Why**: Glanceable, visual engagement driver.

---

#### ✅ 3. **Quick Access Shortcuts (Horizontal Scroll)**

Icons or buttons with labels like:

* `📝 Class Chat`
* `🎭 Clubs`
* `📚 Study Groups`
* `❤️ Vent`
* `➕ Join Group`

Each opens filtered Explore or Chat tabs directly.

**SwiftUI**: Horizontal `ScrollView` with `LazyHStack`.

---

#### ✅ 4. **Live Group Activity Feed**

**Section title**: "Live Now"

A vertical feed showing:

* Group Name (e.g., “BTech CSE Sem 5”)
* Last message snippet
* # of unread messages
* Timestamp (e.g., “2 mins ago”)
* **Join Now** button

Each tile links to the CometChat group chat screen.

> Think of this as “active Slack channels” or “Reddit live threads”.

**Data Model**: From CometChat `GroupListManager` + `lastMessage`.

---

#### ✅ 5. **Upcoming Events Section**

**Section title**: “Upcoming Events”

Each card includes:

* 🗓 Event title
* 📍 Host group (Drama Club)
* ⏰ Date & Time
* ✅ RSVP button
* CTA → `Join Chat`

> This can pull from Firestore + update group chat headers via metadata.

---

#### ✅ 6. **Announcements & Notices (Optional)**

Admin-only broadcast messages:

* “Class suspended tomorrow”
* “Results out on portal”

Styled like system banners. Could use a banner carousel.

---

#### ✅ 7. **Student Spotlight / Fun Polls (Optional MVP+)**

* Poll of the week: “Best canteen dish?”
* Leaderboard for chat participation (gamification)

---

#### ✅ 8. **Bottom Sheet Quick Actions (Floating Button)**

* Tap `➕` FAB to:

  * Start group chat
  * Create event
  * Ask a question
  * Send anonymous message (if enabled)

---

## 📐 SwiftUI Hierarchy Structure (Pseudocode)

```swift
VStack {
    NavigationBar() // Title, Profile, Notifications
    HighlightsCarousel()
    QuickAccessScroll()
    
    ScrollView {
        LiveGroupActivityFeed()
        UpcomingEventsSection()
        AnnouncementsBanner()
    }
}
```

---

## 🎨 Design Style Guide

| Element   | Style                       |
| --------- | --------------------------- |
| Colors    | Blue & White theme          |
| Buttons   | Rounded, filled CTAs        |
| Font      | SF Pro Rounded              |
| Icons     | SF Symbols                  |
| Animation | Subtle transitions, haptics |

---

## 🧠 UX Goals for Home Screen

* **Fast context switching**: User should access what they want in 2 taps max.
* **Campus social layer**: Feels like a digital extension of their real-world community.
* **Balanced**: Not overwhelming, avoids clutter but remains lively.

---

Would you like me to generate a **Figma wireframe**, **SwiftUI implementation**, or **mockup images** of this screen next?
