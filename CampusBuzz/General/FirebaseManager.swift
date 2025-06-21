//
//  FirebaseManager.swift
//  CampusBuzz
//
//  Created by Sharnabh on 21/06/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Create user profile in Firestore
            self?.createUserProfile(user: user) { profileResult in
                switch profileResult {
                case .success:
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    var isUserSignedIn: Bool {
        return currentUser != nil
    }
    
    // MARK: - User Profile Management
    
    func createUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "displayName": user.displayName ?? "",
            "createdAt": Timestamp(),
            "lastActive": Timestamp(),
            "isOnline": true
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateUserProfile(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getUserProfile(uid: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                return
            }
            
            completion(.success(data))
        }
    }
    
    // MARK: - Events Management
    
    func createEvent(_ event: CampusEvent, completion: @escaping (Result<String, Error>) -> Void) {
        let eventData: [String: Any] = [
            "title": event.title,
            "description": event.description,
            "date": Timestamp(date: event.date),
            "location": event.location,
            "organizer": event.organizer,
            "attendees": event.attendees,
            "maxAttendees": event.maxAttendees,
            "isPublic": event.isPublic,
            "createdAt": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("events").addDocument(data: eventData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref!.documentID))
            }
        }
    }
    
    func getEvents(completion: @escaping (Result<[CampusEvent], Error>) -> Void) {
        db.collection("events")
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let events = documents.compactMap { doc -> CampusEvent? in
                    let data = doc.data()
                    return CampusEvent.from(data: data, id: doc.documentID)
                }
                
                completion(.success(events))
            }
    }
    
    // MARK: - Announcements Management
    
    func createAnnouncement(_ announcement: Announcement, completion: @escaping (Result<String, Error>) -> Void) {
        let announcementData: [String: Any] = [
            "title": announcement.title,
            "content": announcement.content,
            "author": announcement.author,
            "priority": announcement.priority.rawValue,
            "isPublic": announcement.isPublic,
            "createdAt": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("announcements").addDocument(data: announcementData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref!.documentID))
            }
        }
    }
    
    func getAnnouncements(completion: @escaping (Result<[Announcement], Error>) -> Void) {
        db.collection("announcements")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let announcements = documents.compactMap { doc -> Announcement? in
                    let data = doc.data()
                    return Announcement.from(data: data, id: doc.documentID)
                }
                
                completion(.success(announcements))
            }
    }
    
    // MARK: - Groups Management (Firestore metadata for CometChat groups)
    
    func saveGroupMetadata(groupId: String, metadata: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("groups").document(groupId).setData(metadata) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getGroupMetadata(groupId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("groups").document(groupId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Group metadata not found"])))
                return
            }
            
            completion(.success(data))
        }
    }
}

// MARK: - Data Models Extensions

extension CampusEvent {
    static func from(data: [String: Any], id: String) -> CampusEvent? {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let timestamp = data["date"] as? Timestamp,
              let location = data["location"] as? String,
              let organizer = data["organizer"] as? String,
              let attendees = data["attendees"] as? [String],
              let maxAttendees = data["maxAttendees"] as? Int,
              let isPublic = data["isPublic"] as? Bool else {
            return nil
        }
        
        return CampusEvent(
            id: id,
            title: title,
            description: description,
            date: timestamp.dateValue(),
            location: location,
            organizer: organizer,
            attendees: attendees,
            maxAttendees: maxAttendees,
            isPublic: isPublic
        )
    }
}

extension Announcement {
    static func from(data: [String: Any], id: String) -> Announcement? {
        guard let title = data["title"] as? String,
              let content = data["content"] as? String,
              let author = data["author"] as? String,
              let priorityString = data["priority"] as? String,
              let priority = AnnouncementPriority(rawValue: priorityString),
              let isPublic = data["isPublic"] as? Bool else {
            return nil
        }
        
        return Announcement(
            id: id,
            title: title,
            content: content,
            author: author,
            priority: priority,
            isPublic: isPublic
        )
    }
}
