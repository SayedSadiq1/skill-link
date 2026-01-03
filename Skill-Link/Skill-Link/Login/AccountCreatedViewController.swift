import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles account created confirmation screen
final class AccountCreatedViewController: BaseViewController {

    // Firestore reference
    private let db = Firestore.firestore()

    // Used to block double actions
    private var isLoading = false

    // Disable back button on this screen
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent swipe back navigation
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    // Runs when continue button is pressed
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isLoading else { return }

        // Get user id from local or auth
        guard let uid = LocalUserStore.currentUserId() ?? Auth.auth().currentUser?.uid else {
            showAlert("You are not logged in. Please login again.")
            return
        }

        isLoading = true
        sender.isEnabled = false

        // Read user role from firestore
        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                sender.isEnabled = true

                if let err = err {
                    self.showAlert("Failed reading role: \(err.localizedDescription)")
                    return
                }

                let data = snap?.data() ?? [:]
                let role = (data["role"] as? String ?? "").lowercased()

                let sb = UIStoryboard(name: "login", bundle: nil)

                // Navigate based on selected role
                if role == "provider" {
                    let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController1")
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if role == "seeker" {
                    let vc = sb.instantiateViewController(withIdentifier: "SetupProfileSeekerViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert("Role is missing. Please select role again.")
                }
            }
        }
    }

    // Shows simple alert popup
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Account Created", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
