//
//  HomeModels.swift
//  CampusBuzz
//
//  Created by System on 21/06/25.
//

import Foundation

// MARK: - Highlight Item

struct HighlightItem {
    let title: String
    let description: String
    let imageURL: String?
    let actionURL: String?
}

// MARK: - Quick Access Item

struct QuickAccessItem {
    let title: String
    let icon: String
    let action: QuickAccessAction
}

enum QuickAccessAction {
    case groups
    case events
    case polls
    case study
    case marketplace
    case sports
}

// MARK: - Event Item

struct EventItem {
    let title: String
    let date: Date
    let location: String
    let attendeeCount: Int
}

// MARK: - Campus Announcement

struct AnnouncementItem {
    let title: String
    let content: String
    let author: String
    let date: Date
    let priority: AnnouncementPriority
}

enum AnnouncementPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "Info"
        case .medium: return "Notice"
        case .high: return "Important"
        case .urgent: return "Urgent"
        }
    }
}

// MARK: - Poll Item

struct PollItem {
    let id: String
    let question: String
    let options: [PollOption]
    let totalVotes: Int
    let endDate: Date?
    let creator: String
}

struct PollOption {
    let id: String
    let text: String
    let votes: Int
}

// MARK: - Firebase Data Models

struct CampusEvent {
    let id: String
    let title: String
    let description: String
    let date: Date
    let location: String
    let organizer: String
    let attendees: [String]
    let maxAttendees: Int
    let isPublic: Bool
    
    init(id: String = UUID().uuidString, title: String, description: String, date: Date, location: String, organizer: String, attendees: [String] = [], maxAttendees: Int, isPublic: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.location = location
        self.organizer = organizer
        self.attendees = attendees
        self.maxAttendees = maxAttendees
        self.isPublic = isPublic
    }
}

struct Announcement {
    let id: String
    let title: String
    let content: String
    let author: String
    let priority: AnnouncementPriority
    let isPublic: Bool
    
    init(id: String = UUID().uuidString, title: String, content: String, author: String, priority: AnnouncementPriority, isPublic: Bool = true) {
        self.id = id
        self.title = title
        self.content = content
        self.author = author
        self.priority = priority
        self.isPublic = isPublic
    }
}

// MARK: - User Profile

struct UserProfile {
    let uid: String
    let email: String
    let displayName: String
    let createdAt: Date
    let lastActive: Date
    let isOnline: Bool
    
    init(uid: String, email: String, displayName: String, createdAt: Date = Date(), lastActive: Date = Date(), isOnline: Bool = true) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.lastActive = lastActive
        self.isOnline = isOnline
    }
}
