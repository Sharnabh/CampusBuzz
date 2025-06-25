import Foundation
import CometChatSDK

// MARK: - Explore Category

enum ExploreCategory: String, CaseIterable {
    case all = "all"
    case academics = "academics"
    case clubs = "clubs"
    case sports = "sports"
    case gaming = "gaming"
    case career = "career"
    case dormLife = "dormLife"
    
    var displayName: String {
        switch self {
        case .all: return "🔍 All"
        case .academics: return "🏫 Academics"
        case .clubs: return "🎭 Clubs"
        case .sports: return "🏋️‍♂️ Sports"
        case .gaming: return "🎮 Gaming"
        case .career: return "💼 Career"
        case .dormLife: return "🛏️ Dorm Life"
        }
    }
    
    var searchKeyword: String {
        switch self {
        case .all: return ""
        case .academics: return "academic"
        case .clubs: return "club"
        case .sports: return "sports"
        case .gaming: return "gaming"
        case .career: return "career"
        case .dormLife: return "dorm"
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "magnifyingglass"
        case .academics: return "book.fill"
        case .clubs: return "theatermasks.fill"
        case .sports: return "sportscourt.fill"
        case .gaming: return "gamecontroller.fill"
        case .career: return "briefcase.fill"
        case .dormLife: return "bed.double.fill"
        }
    }
}

// MARK: - Group Extension for Explore

extension Group {
    var exploreCategory: ExploreCategory {
        // Check metadata for category information
        if let metadata = self.metadata {
            var categoryString: String? = nil
            
            // First try direct metadata access (current format)
            categoryString = metadata["category"] as? String ?? metadata["type"] as? String
            
            // Fallback: Check if metadata contains JSON format (legacy support)
            if categoryString == nil,
               let jsonString = metadata["json"] as? String,
               let jsonData = jsonString.data(using: .utf8),
               let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                categoryString = jsonDict["category"] as? String ?? jsonDict["type"] as? String
            }
            
            if let categoryString = categoryString {
                switch categoryString.lowercased() {
                case "academic", "study", "semester":
                    return .academics
                case "club", "society":
                    return .clubs
                case "sport", "sports", "fitness", "gym":
                    return .sports
                case "gaming", "game", "esports":
                    return .gaming
                case "career", "job", "internship", "general":
                    return .career
                case "dorm", "hostel", "residence":
                    return .dormLife
                default:
                    break
                }
            }
        }
        
        // Fallback to name-based categorization
        guard let name = self.name?.lowercased() else { return .all }
        
        if name.contains("academic") || name.contains("study") || name.contains("sem") || name.contains("course") || name.contains("math") || name.contains("engineering") {
            return .academics
        } else if name.contains("club") || name.contains("society") || name.contains("drama") || name.contains("photography") {
            return .clubs
        } else if name.contains("sport") || name.contains("gym") || name.contains("fitness") || name.contains("basketball") || name.contains("football") {
            return .sports
        } else if name.contains("gaming") || name.contains("game") || name.contains("esports") || name.contains("squad") {
            return .gaming
        } else if name.contains("career") || name.contains("job") || name.contains("internship") || name.contains("startup") {
            return .career
        } else if name.contains("dorm") || name.contains("hostel") || name.contains("residence") || name.contains("block") {
            return .dormLife
        }
        
        return .all
    }
    
    var isPublicGroup: Bool {
        return self.groupType == .public
    }
    
    var memberCountText: String {
        let count = Int(self.membersCount)
        if count == 1 {
            return "1 member"
        } else {
            return "\(count) members"
        }
    }
    
    var groupTypeDisplayText: String {
        switch self.groupType {
        case .public:
            return "Public"
        case .private:
            return "Private"
        case .password:
            return "Password Protected"
        @unknown default:
            return "Unknown"
        }
    }
    
    var firstLetterForIcon: String {
        return String(self.name?.first ?? "G").uppercased()
    }
    
    // Helper function to extract metadata values safely
    func getMetadataValue(key: String) -> String? {
        guard let metadata = self.metadata else { return nil }
        
        // Check if metadata contains JSON
        if let jsonString = metadata["json"] as? String,
           let jsonData = jsonString.data(using: .utf8),
           let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return jsonDict[key] as? String
        }
        
        // Fallback to direct metadata access
        return metadata[key] as? String
    }
    
    var college: String? {
        return getMetadataValue(key: "college")
    }
    
    var groupCreator: String? {
        return getMetadataValue(key: "created_by")
    }
}

// MARK: - Featured Group Item

struct FeaturedGroupItem {
    let group: Group
    let description: String
    let badge: String? // e.g., "Trending", "New", "Recommended"
    
    init(group: Group, description: String? = nil, badge: String? = nil) {
        self.group = group
        self.description = description ?? group.groupDescription ?? "Join this amazing community!"
        self.badge = badge
    }
}

// MARK: - Suggested Group Item

struct SuggestedGroupItem {
    let group: Group
    let reason: String // e.g., "Because you joined BTech CSE Sem 5"
    
    init(group: Group, reason: String) {
        self.group = group
        self.reason = reason
    }
}

// MARK: - Group Metadata (for Firestore integration)

struct GroupMetadata {
    let groupId: String
    let name: String
    let description: String
    let tags: [String]
    let creatorUID: String
    let type: String // "public", "private", "password"
    let memberCount: Int
    let createdAt: Date
    let category: ExploreCategory
    let isFeatured: Bool
    let featuredReason: String?
    
    init(groupId: String, name: String, description: String, tags: [String], creatorUID: String, type: String, memberCount: Int, createdAt: Date = Date(), category: ExploreCategory = .all, isFeatured: Bool = false, featuredReason: String? = nil) {
        self.groupId = groupId
        self.name = name
        self.description = description
        self.tags = tags
        self.creatorUID = creatorUID
        self.type = type
        self.memberCount = memberCount
        self.createdAt = createdAt
        self.category = category
        self.isFeatured = isFeatured
        self.featuredReason = featuredReason
    }
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "groupId": groupId,
            "name": name,
            "description": description,
            "tags": tags,
            "creatorUID": creatorUID,
            "type": type,
            "memberCount": memberCount,
            "createdAt": createdAt,
            "category": category.rawValue,
            "isFeatured": isFeatured,
            "featuredReason": featuredReason ?? ""
        ]
    }
    
    // Create from Firestore data
    static func from(data: [String: Any], id: String) -> GroupMetadata? {
        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let tags = data["tags"] as? [String],
              let creatorUID = data["creatorUID"] as? String,
              let type = data["type"] as? String,
              let memberCount = data["memberCount"] as? Int else {
            return nil
        }
        
        let createdAt = (data["createdAt"] as? Date) ?? Date()
        let categoryString = data["category"] as? String ?? "all"
        let category = ExploreCategory(rawValue: categoryString) ?? .all
        let isFeatured = data["isFeatured"] as? Bool ?? false
        let featuredReason = data["featuredReason"] as? String
        
        return GroupMetadata(
            groupId: id,
            name: name,
            description: description,
            tags: tags,
            creatorUID: creatorUID,
            type: type,
            memberCount: memberCount,
            createdAt: createdAt,
            category: category,
            isFeatured: isFeatured,
            featuredReason: featuredReason
        )
    }
}

// MARK: - Search Result Item

struct GroupSearchResult {
    let group: Group
    let matchType: SearchMatchType
    let highlightedText: String?
    
    enum SearchMatchType {
        case name
        case description
        case tag
        case category
    }
}

// MARK: - Filter Options

struct ExploreFilterOptions {
    var selectedCategories: Set<ExploreCategory>
    var groupTypes: Set<GroupType>
    var memberCountRange: ClosedRange<Int>?
    var sortBy: SortOption
    
    enum GroupType {
        case `public`
        case `private`
        case passwordProtected
    }
    
    enum SortOption {
        case name
        case memberCount
        case dateCreated
        case activity
    }
    
    init() {
        self.selectedCategories = [.all]
        self.groupTypes = [.public, .private, .passwordProtected]
        self.memberCountRange = nil
        self.sortBy = .memberCount
    }
}
