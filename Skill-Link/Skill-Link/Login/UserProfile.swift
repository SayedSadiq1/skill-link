enum UserRole: String, Codable {
    case provider
    case seeker
}

struct UserProfile: Codable {
    var name: String
    var skills: [String]
    var brief: String
    var contact: String
    var imageURL: String?
    var id: String? = nil
//    var role: UserRole
}
