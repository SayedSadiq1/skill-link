import Foundation

final class LocalUserStore {

    private static let key = "userProfile"

    // Save profile locally
    static func save(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Load profile locally
    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    // Clear profile on logout
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
