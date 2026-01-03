import Foundation
import FirebaseFirestore

// Defines what type of user this is
enum UserRole: String, Codable {
    case provider
    case seeker
}

// Model that represents a user profile
struct UserProfile: Codable {

    // Firebase user id from auth
    @DocumentID<String> var id: String?

    // User basic details
    var fullName: String
    var contact: String?
    var imageURL: String?

    // Role of the user
    var role: UserRole = .seeker

    // Extra info used only for providers
    var skills: [String]?
    var brief: String?

    // Flag to disable account if needed
    var isSuspended: Bool = false

    // Checks if user is provider
    var isProvider: Bool { role == .provider }

    // Checks if user is seeker
    var isSeeker: Bool { role == .seeker }
}

// Stores user profile locally on device
final class LocalUserStore {

    // Key used for saving profile
    private static let profileKey = "userProfile"

    // Save profile into user defaults
    static func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    // Load saved profile from device
    static func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    // Remove saved profile on logout
    static func clearProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }

    // Get current user id quickly
    static func currentUserId() -> String? {
        loadProfile()?.id
    }

    // Get current user role quickly
    static func currentRole() -> UserRole? {
        loadProfile()?.role
    }
}
