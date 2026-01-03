import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles role selection screen logic
final class RoleSelectionViewController: BaseViewController {

    // Card views for role selection
    @IBOutlet weak var providerCardView: UIView!
    @IBOutlet weak var seekerCardView: UIView!

    // Firestore reference
    private let db = Firestore.firestore()

    // Used to block double save
    private var isSaving = false

    // Disable back button on this screen
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent swipe back navigation
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Apply card styling
        styleCard(providerCardView)
        styleCard(seekerCardView)
    }

    // Styles role cards UI
    private func styleCard(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
    }

    // Runs when provider card is tapped
    @IBAction func providerTapped(_ sender: UIButton) {
        setRole(.provider)
    }

    // Runs when seeker card is tapped
    @IBAction func seekerTapped(_ sender: UIButton) {
        setRole(.seeker)
    }

    // Saves selected role to firestore
    private func setRole(_ role: UserRole) {
        guard !isSaving else { return }

        guard let user = Auth.auth().currentUser else {
            showAlert("You are not logged in. Please login again.")
            return
        }

        isSaving = true

        let data: [String: Any] = [
            "role": role.rawValue,
            "profileCompleted": false
        ]

        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            self.isSaving = false

            if let error = error {
                self.showAlert("Failed to save role: \(error.localizedDescription)")
                return
            }

            // Update role in local storage
            self.updateRoleLocally(role)
        }
    }

    // Updates role inside local profile
    private func updateRoleLocally(_ role: UserRole) {
        guard var profile = LocalUserStore.loadProfile() else { return }
        profile.role = role
        LocalUserStore.saveProfile(profile)
    }

    // Shows alert message
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Role Selection", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
