//
//  CometChatConfig.swift
//  CampusBuzz
//
//  Created by Sharnabh on 21/06/25.
//

import Foundation
import CometChatSDK

struct CometChatConfig {
    
    // MARK: - CometChat Credentials
    // Using your configured credentials
    static let appID = "277721deb05dda5c"
    static let region = "IN" // India region
    static let authKey = "d4df456ef23f05f772fbde89982edd1dd1f4d6f6"
    
    // MARK: - App Constants
    static let appName = "CampusBuzz"
    static let appVersion = "1.0.0"
    
    // MARK: - User Roles
    enum UserRole: String {
        case student = "student"
        case faculty = "faculty"
        case admin = "admin"
    }
    
    // MARK: - Group Types
    enum GroupType: String {
        case semester = "semester"      // BTech CSE Sem 5
        case club = "club"             // Drama Club
        case course = "course"         // Data Structures
        case general = "general"       // General Discussion
        case study = "study"           // Study Groups
    }
    
    // MARK: - Media Settings
    struct MediaSettings {
        static let maxImageSize: Int64 = 10 * 1024 * 1024  // 10MB
        static let maxVideoSize: Int64 = 50 * 1024 * 1024  // 50MB
        static let maxFileSize: Int64 = 20 * 1024 * 1024   // 20MB
        static let allowedImageTypes = ["jpg", "jpeg", "png", "gif"]
        static let allowedVideoTypes = ["mp4", "mov", "avi"]
        static let allowedFileTypes = ["pdf", "doc", "docx", "txt", "ppt", "pptx"]
    }
    
    // MARK: - Helper Methods
    static func isConfigured() -> Bool {
        return !appID.isEmpty && 
               !region.isEmpty && 
               !authKey.isEmpty &&
               appID != "YOUR_COMETCHAT_APP_ID"
    }
}

// MARK: - CometChat Extensions
extension CometChatConfig {
    
    // Generate group GUID based on college and type
    static func generateGroupGUID(college: String, type: GroupType, name: String) -> String {
        let sanitizedCollege = college.lowercased().replacingOccurrences(of: " ", with: "_")
        let sanitizedName = name.lowercased().replacingOccurrences(of: " ", with: "_")
        return "\(sanitizedCollege)_\(type.rawValue)_\(sanitizedName)"
    }
    
    // Generate user UID (can be based on college email or custom format)
    static func generateUserUID(email: String) -> String {
        return email.lowercased().replacingOccurrences(of: "@", with: "_at_")
    }
    
    // Create CometChat user object for profile setup
    static func createCometChatUser(uid: String, name: String, email: String? = nil, avatar: String? = nil, role: UserRole = .student) -> User {
        let user = User(uid: uid, name: name)
        
        if let avatar = avatar {
            user.avatar = avatar
        }
        
        // Set metadata for role and other campus-specific info
        var metadata: [String: Any] = [
            "role": role.rawValue,
            "app_version": appVersion
        ]
        
        // Store email in metadata since User class doesn't have email property
        if let email = email {
            metadata["email"] = email
        }
        
        user.metadata = metadata
        
        return user
    }
    
    // Validate media before upload
    static func validateMedia(fileURL: URL, type: MediaType) -> (isValid: Bool, error: String?) {
        let fileSize = getFileSize(url: fileURL)
        let fileExtension = fileURL.pathExtension.lowercased()
        
        switch type {
        case .image:
            if fileSize > MediaSettings.maxImageSize {
                return (false, "Image size exceeds 10MB limit")
            }
            if !MediaSettings.allowedImageTypes.contains(fileExtension) {
                return (false, "Image format not supported. Use: \(MediaSettings.allowedImageTypes.joined(separator: ", "))")
            }
        case .video:
            if fileSize > MediaSettings.maxVideoSize {
                return (false, "Video size exceeds 50MB limit")
            }
            if !MediaSettings.allowedVideoTypes.contains(fileExtension) {
                return (false, "Video format not supported. Use: \(MediaSettings.allowedVideoTypes.joined(separator: ", "))")
            }
        case .file:
            if fileSize > MediaSettings.maxFileSize {
                return (false, "File size exceeds 20MB limit")
            }
            if !MediaSettings.allowedFileTypes.contains(fileExtension) {
                return (false, "File format not supported. Use: \(MediaSettings.allowedFileTypes.joined(separator: ", "))")
            }
        }
        
        return (true, nil)
    }
    
    private static func getFileSize(url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
}

// MARK: - Media Type Enum
enum MediaType {
    case image
    case video
    case file
}
