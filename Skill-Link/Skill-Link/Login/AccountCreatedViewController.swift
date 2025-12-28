import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountCreatedViewController: UIViewController {

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    private func hideBackButton() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @IBAction func continueTapped(_ sender: UIButton) {

        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert("No user session. Please login again.")
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            if let err = err {
                self.showAlert("Failed reading role: \(err.localizedDescription)")
                return
            }

            let role = (snap?.data()?["role"] as? String ?? "").lowercased()

            if role == "provider" {
                // ✅ Go to provider setup/profile (your current provider setup screen)
                let sb = UIStoryboard(name: "login", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController1")
                self.navigationController?.pushViewController(vc, animated: true)

            } else if role == "seeker" {
                // ✅ for now (since seeker screen not made)
                self.showAlert("Seeker setup is not ready yet.")

            } else {
                self.showAlert("Role is missing. Please select role again.")
            }
        }
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Account Created", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
