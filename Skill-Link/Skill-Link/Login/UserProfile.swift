import Foundation

enum UserRole: String, Codable {
    case provider
    case seeker
}

struct UserProfile: Codable {

    // Firebase UID (always exists after login/register)
    let id: String

    // Basic info
    var name: String
    var contact: String
    var imageURL: String?

    // Role
    var role: UserRole

    // Provider-only data (empty for seeker)
    var skills: [String]
    var brief: String

    // Account state (admin control)
    var isSuspended: Bool

    // MARK: - Helpers

    var isProvider: Bool { role == .provider }
    var isSeeker: Bool { role == .seeker }
}

// MARK: - Local User Store
// Used after register + login + profile load
final class LocalUserStore {

    private static let profileKey = "userProfile"

    // Save profile locally
    static func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    // Load saved profile
    static func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    // Clear profile on sign out / delete
    static func clearProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }

    // Shortcut: current logged-in user UID
    static func currentUserId() -> String? {
        loadProfile()?.id
    }

    // Shortcut: current role
    static func currentRole() -> UserRole? {
        loadProfile()?.role
    }
}
