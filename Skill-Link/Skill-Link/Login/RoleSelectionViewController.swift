import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RoleSelectionViewController: BaseViewController {

    @IBOutlet weak var providerCardView: UIView!
    @IBOutlet weak var seekerCardView: UIView!

    private let db = Firestore.firestore()
    private var isSaving = false

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Stop user from going back from here
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Style the 2 cards so they look like the figma ones
        styleCard(providerCardView)
        styleCard(seekerCardView)
    }

    // MARK: - Card Style
    private func styleCard(_ view: UIView) {
        // Rounded corners like the design
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = false

        // Border around the card
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        // Shadow for depth (figma style)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 10)

        // If you want the card to clip inside content, use a subview for content
        // Dont set masksToBounds = true here or the shadow will disapear
    }

    // MARK: - Button Actions
    @IBAction func providerTapped(_ sender: UIButton) {
        setRole(role: "provider")
    }

    @IBAction func seekerTapped(_ sender: UIButton) {
        setRole(role: "seeker")
    }

    // MARK: - Save role
    private func setRole(role: String) {
        guard !isSaving else { return }

        guard let user = Auth.auth().currentUser else {
            showAlert("You are not logged-in. Please login again.")
            return
        }

        isSaving = true

        let data: [String: Any] = [
            "role": role,
            "profileCompleted": false
        ]

        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }

            self.isSaving = false

            if let error = error {
                self.showAlert("Failed to save role: \(error.localizedDescription)")
                return
            }

            // Save role localy too so other screens can read it fast
            self.saveRoleLocally(role: role, uid: user.uid)

            // Navigation is still handled by your storyboard segue
        }
    }

    // MARK: - Local save
    private func saveRoleLocally(role: String, uid: String) {
        // Load current local profile if it exists, then update role fields
        var localProfile = loadLocalUserProfile() ?? UserProfile(
            name: "",
            skills: [],
            brief: "",
            contact: "",
            imageURL: nil,
            id: uid
        )

        localProfile.id = uid

        // We dont have role in UserProfile struct, so we store it as a seperate key
        UserDefaults.standard.set(role, forKey: "userRole")

        // Save profile too (even if empty for now)
        if let data = try? JSONEncoder().encode(localProfile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }

    private func loadLocalUserProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "userProfile") else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    // MARK: - Alert
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Role Selection", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
