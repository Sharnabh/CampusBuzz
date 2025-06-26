//
//  CometChatManager.swift
//  CampusBuzz
//
//  Created by System on 21/06/25.
//

import Foundation
import CometChatSDK
import CometChatUIKitSwift

// Custom error type for CometChat operations
enum CometChatManagerError: Error {
    case initializationFailed(String)
    case loginFailed(String)
    case userCreationFailed(String)
    case groupCreationFailed(String)
    case mediaSendFailed(String)
    case noUserLoggedIn
    case invalidMedia(String)
    
    var localizedDescription: String {
        switch self {
        case .initializationFailed(let message):
            return "Initialization failed: \(message)"
        case .loginFailed(let message):
            return "Login failed: \(message)"
        case .userCreationFailed(let message):
            return "User creation failed: \(message)"
        case .groupCreationFailed(let message):
            return "Group creation failed: \(message)"
        case .mediaSendFailed(let message):
            return "Media send failed: \(message)"
        case .noUserLoggedIn:
            return "No user logged in"
        case .invalidMedia(let message):
            return "Invalid media: \(message)"
        }
    }
}

class CometChatManager {
    
    static let shared = CometChatManager()
    private init() {}
    
    // MARK: - Status Check
    
    /// Check if CometChat is properly initialized and ready
    func checkCometChatStatus() -> (isReady: Bool, message: String) {
        // Check if configuration is valid
        guard CometChatConfig.isConfigured() else {
            return (false, "CometChat configuration is invalid")
        }
        
        // Check if there's network connectivity (basic check)
        // Note: You might want to add a proper network reachability check
        
        // Check if SDK is initialized by trying to get current settings
        let loggedInUser = CometChatUIKit.getLoggedInUser()
        
        if loggedInUser != nil {
            return (true, "CometChat is ready - User logged in")
        } else {
            return (true, "CometChat is ready - No user logged in")
        }
    }
    
    // MARK: - User Management
    
    /// Login user to CometChat
    func loginUser(uid: String, completion: @escaping (Result<User, CometChatManagerError>) -> Void) {
        // Check if UID is valid
        guard !uid.isEmpty else {
            completion(.failure(.loginFailed("Invalid UID: UID cannot be empty")))
            return
        }
        
        print("🔐 Attempting to login user: \(uid)")
        
        CometChatUIKit.login(uid: uid) { result in
            switch result {
            case .success(let user):
                print("✅ User login successful: \(user.uid ?? "unknown")")
                completion(.success(user))
            case .onError(let error):
                let errorMessage = error.errorDescription
                print("❌ User login failed: \(errorMessage)")
                print("   Error details: \(error)")
                completion(.failure(.loginFailed(errorMessage)))
            @unknown default:
                print("❌ Unknown login error occurred")
                completion(.failure(.loginFailed("Unknown login error")))
            }
        }
    }
    
    
    /// Create and register a new user
    func createUser(uid: String, name: String, email: String?, avatar: String? = nil, role: CometChatConfig.UserRole = .student, completion: @escaping (Result<User, CometChatManagerError>) -> Void) {
        
        let user = CometChatConfig.createCometChatUser(uid: uid, name: name, email: email, avatar: avatar, role: role)
        
        CometChat.createUser(user: user, authKey: CometChatConfig.authKey) { createdUser in
            print("✅ User created successfully: \(createdUser.uid ?? "unknown")")
            completion(.success(createdUser))
        } onError: { error in
            print("❌ User creation failed: \(error?.errorDescription ?? "Unknown error")")
            completion(.failure(.userCreationFailed(error?.errorDescription ?? "Unknown error")))
        }
    }
    
    /// Update current user profile
    func updateUserProfile(name: String? = nil, avatar: String? = nil, metadata: [String: Any]? = nil, completion: @escaping (Result<User, CometChatManagerError>) -> Void) {
        
        guard let currentUser = CometChatUIKit.getLoggedInUser() else {
            completion(.failure(.noUserLoggedIn))
            return
        }
        
        let updatedUser = User(uid: currentUser.uid ?? "", name: name ?? currentUser.name ?? "")
        
        if let avatar = avatar {
            updatedUser.avatar = avatar
        }
        
        if let metadata = metadata {
            updatedUser.metadata = metadata
        }
        
        CometChat.updateCurrentUserDetails(user: updatedUser) { user in
            completion(.success(user))
        } onError: { error in
            completion(.failure(.userCreationFailed(error?.errorDescription ?? "Update failed")))
        }
    }
    
    /// Logout current user
    func logoutUser(completion: @escaping (Result<Void, CometChatManagerError>) -> Void) {
        CometChat.logout { _ in
            completion(.success(()))
        } onError: { error in
            let errorMessage = error.errorDescription
            completion(.failure(.loginFailed(errorMessage)))
        }
    }
    
    
    // MARK: - Group Management
    
    /// Create a campus group (semester, club, course, etc.)
    func createCampusGroup(name: String, type: CometChatConfig.GroupType, college: String, description: String? = nil, completion: @escaping (Result<Group, CometChatManagerError>) -> Void) {
        
        let guid = CometChatConfig.generateGroupGUID(college: college, type: type, name: name)
        let group = Group(guid: guid, name: name, groupType: .public, password: nil)
        
        if let description = description {
            group.groupDescription = description
        }
        
        // Set group metadata for campus-specific info
        let metadataDict: [String: String] = [
            "type": type.rawValue,
            "college": college,
            "created_by": "CampusBuzz"
        ]
        
        // Store metadata directly as string dictionary (CometChat compatible format)
        group.metadata = metadataDict
        print("📝 Group metadata set: \(metadataDict)")
        
        CometChat.createGroup(group: group) { createdGroup in
            print("✅ Group created: \(createdGroup.guid)")
            completion(.success(createdGroup))
        } onError: { error in
            print("❌ Group creation failed: \(error?.errorDescription ?? "Unknown error")")
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Unknown error")))
        }
    }
    
    /// Join a group
    func joinGroup(guid: String, completion: @escaping (Result<Group, CometChatManagerError>) -> Void) {
        CometChat.joinGroup(GUID: guid, groupType: .public, password: nil) { group in
            completion(.success(group))
        } onError: { error in
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Failed to join group")))
        }
    }
    
    /// Get list of groups user has joined
    func getJoinedGroups(completion: @escaping (Result<[Group], CometChatManagerError>) -> Void) {
        let groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 30).set(joinedOnly: true).build()
        
        groupRequest.fetchNext { groups in
            completion(.success(groups))
        } onError: { error in
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Failed to fetch groups")))
        }
    }
    
    /// Fetch groups for Home screen - gets both joined and public groups
    func fetchGroups(completion: @escaping (Result<[Group], CometChatManagerError>) -> Void) {
        let groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 50).build()
        
        groupRequest.fetchNext { groups in
            completion(.success(groups))
        } onError: { error in
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Failed to fetch groups")))
        }
    }
    
    /// Search for public groups
    func searchGroups(searchTerm: String, completion: @escaping (Result<[Group], CometChatManagerError>) -> Void) {
        let groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 20)
            .set(searchKeyword: searchTerm)
            .build()
        
        groupRequest.fetchNext { groups in
            completion(.success(groups))
        } onError: { error in
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Search failed")))
        }
    }
    
    /// Add members to a group
    func addMembersToGroup(groupGUID: String, users: [User], completion: @escaping (Result<[String: Any]?, CometChatManagerError>) -> Void) {
        print("🏗️ Adding \(users.count) members to group: \(groupGUID)")
        
        var groupMembers: [GroupMember] = []
        
        for user in users {
            let member = GroupMember(UID: user.uid ?? "", groupMemberScope: .participant)
            groupMembers.append(member)
        }
        
        CometChat.addMembersToGroup(guid: groupGUID, groupMembers: groupMembers) { response in
            print("✅ Successfully added members to group")
            completion(.success(response))
        } onError: { error in
            print("❌ Failed to add members to group: \(error?.errorDescription ?? "Unknown error")")
            completion(.failure(.groupCreationFailed(error?.errorDescription ?? "Failed to add members")))
        }
    }
    
    /// Create sample groups for demo purposes
    func createSampleGroupsBatch(completion: @escaping (Result<[Group], CometChatManagerError>) -> Void) {
        print("🏗️ CometChatManager: Creating batch sample groups...")
        
        let sampleGroupsData = [
            ("CS Engineering Hub", CometChatConfig.GroupType.semester, "Computer Science Engineering students community", "🎓"),
            ("Photography Club", CometChatConfig.GroupType.club, "Capture moments, share techniques, organize photo walks", "📸"),
            ("Drama Society", CometChatConfig.GroupType.club, "Theater and performing arts community", "🎭"),
            ("Basketball Team", CometChatConfig.GroupType.club, "Join our basketball training sessions", "🏀"),
            ("Study Group - Math", CometChatConfig.GroupType.study, "Solve math problems together", "📐"),
            ("Career Guidance", CometChatConfig.GroupType.general, "Get advice on internships and job opportunities", "💼"),
            ("Tech Startups", CometChatConfig.GroupType.general, "Discuss entrepreneurship and startup ideas", "🚀"),
            ("Gaming Squad", CometChatConfig.GroupType.club, "Discuss latest games and organize tournaments", "🎮"),
            ("Fitness Enthusiasts", CometChatConfig.GroupType.club, "Share workout tips and motivate each other", "💪"),
            ("Music Society", CometChatConfig.GroupType.club, "For music lovers - share talent, organize concerts", "🎵")
        ]
        
        let college = "Demo University"
        var createdGroups: [Group] = []
        var errorCount = 0
        let totalGroups = sampleGroupsData.count
        
        let dispatchGroup = DispatchGroup()
        
        for (index, groupData) in sampleGroupsData.enumerated() {
            let (name, type, description, icon) = groupData
            
            dispatchGroup.enter()
            
            // Add timestamp to ensure uniqueness
            let uniqueName = "\(icon) \(name)"
            let timestamp = Int(Date().timeIntervalSince1970)
            let guid = "demo_\(type.rawValue)_\(timestamp)_\(index)"
            
            let group = Group(guid: guid, name: uniqueName, groupType: .public, password: nil)
            group.groupDescription = description
            
            // Set metadata directly as string dictionary (CometChat compatible format)
            let metadataDict: [String: String] = [
                "type": type.rawValue,
                "college": college,
                "created_by": "CampusBuzz_Demo",
                "category": type.rawValue
            ]
            
            group.metadata = metadataDict
            print("📝 Group metadata set: \(metadataDict)")
            
            print("🏗️ Creating group: \(uniqueName) with GUID: \(guid)")
            
            // Use delay instead of blocking sleep
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                CometChat.createGroup(group: group) { createdGroup in
                    print("✅ Successfully created: \(createdGroup.name ?? "Unknown") - \(createdGroup.guid)")
                    createdGroups.append(createdGroup)
                    dispatchGroup.leave()
                } onError: { error in
                    print("❌ Failed to create '\(uniqueName)': \(error?.errorDescription ?? "Unknown error")")
                    errorCount += 1
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("🏁 Batch creation completed: \(createdGroups.count) success, \(errorCount) errors")
            
            if createdGroups.isEmpty {
                completion(.failure(.groupCreationFailed("Failed to create any groups")))
            } else {
                completion(.success(createdGroups))
            }
        }
    }
    
    // MARK: - Media Handling
    
    /// Send text message
    func sendTextMessage(to receiverID: String, receiverType: CometChat.ReceiverType, text: String, completion: @escaping (Result<TextMessage, CometChatManagerError>) -> Void) {
        
        let textMessage = TextMessage(receiverUid: receiverID, text: text, receiverType: receiverType)
        
        CometChat.sendTextMessage(message: textMessage) { message in
            completion(.success(message))
        } onError: { error in
            completion(.failure(.mediaSendFailed(error?.errorDescription ?? "Failed to send message")))
        }
    }
    
    /// Validate media before upload
    private func validateMediaFile(fileURL: URL, type: MediaType) -> (isValid: Bool, error: String?) {
        let validation = CometChatConfig.validateMedia(fileURL: fileURL, type: type)
        return validation
    }
    
    // MARK: - Utility Methods
    
    /// Check if user is logged in
    func isUserLoggedIn() -> Bool {
        return CometChatUIKit.getLoggedInUser() != nil
    }
    
    /// Get current logged in user
    func getCurrentUser() -> User? {
        return CometChatUIKit.getLoggedInUser()
    }
    
    /// Get conversations component for navigation
    @MainActor
    func getConversationsComponent() -> CometChatConversations {
        return CometChatConversations()
    }
    
    /// Get groups component for navigation
    @MainActor
    func getGroupsComponent() -> CometChatGroups {
        return CometChatGroups()
    }
    
    /// Get users component for finding other users
    @MainActor
    func getUsersComponent() -> CometChatUsers {
        return CometChatUsers()
    }
}

// MARK: - Campus-Specific Extensions
extension CometChatManager {
    
    /// Quick method to join common campus groups
    func joinCommonCampusGroups(college: String, semester: String, course: String, completion: @escaping (Result<[Group], CometChatManagerError>) -> Void) {
        
        let commonGroups = [
            CometChatConfig.generateGroupGUID(college: college, type: .semester, name: semester),
            CometChatConfig.generateGroupGUID(college: college, type: .course, name: course),
            CometChatConfig.generateGroupGUID(college: college, type: .general, name: "General Discussion")
        ]
        
        var joinedGroups: [Group] = []
        var hasError = false
        let dispatchGroup = DispatchGroup()
        
        for groupGUID in commonGroups {
            dispatchGroup.enter()
            joinGroup(guid: groupGUID) { result in
                switch result {
                case .success(let group):
                    joinedGroups.append(group)
                case .failure(_):
                    hasError = true
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if hasError {
                completion(.failure(.groupCreationFailed("Some groups could not be joined")))
            } else {
                completion(.success(joinedGroups))
            }
        }
    }
}
