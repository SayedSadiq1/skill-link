import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RoleSelectionViewController: BaseViewController {

    private let db = Firestore.firestore()
    private var isSaving = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    // Connect this to Provider button (Touch Up Inside)
    @IBAction func providerTapped(_ sender: UIButton) {
        setRole(role: "provider")
    }

    // Connect this to Seeker button (Touch Up Inside)
    @IBAction func seekerTapped(_ sender: UIButton) {
        setRole(role: "seeker")
    }

    private func setRole(role: String) {
        guard !isSaving else { return }
        guard let user = Auth.auth().currentUser else {
            showAlert("No logged-in user found. Please register again.")
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

            // ✅ DO NOTHING HERE
            // Navigation is handled by storyboard segue connected to the button
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Role Selection",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
