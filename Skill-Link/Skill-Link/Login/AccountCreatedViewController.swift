import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountCreatedViewController: BaseViewController {

    private let db = Firestore.firestore()
    private var isLoading = false

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // stop user from going back to register/login screens
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        // stop double taps
        guard !isLoading else { return }

        // use local user first, fallback to auth just in case
        guard let uid = LocalUserStore.currentUserId() ?? Auth.auth().currentUser?.uid else {
            showAlert("You are not logged in. Please login again.")
            return
        }

        isLoading = true
        sender.isEnabled = false

        // read the role and decide where to go next
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

                // go to the right setup screen based on role
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

    private func showAlert(_ msg: String) {
        // basic alert for this screen
        let alert = UIAlertController(title: "Account Created", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
