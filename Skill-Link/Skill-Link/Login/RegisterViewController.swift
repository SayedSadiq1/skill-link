import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RegisterViewController: BaseViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let db = Firestore.firestore()
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isLoading else { return }

        let fullName = (fullNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !fullName.isEmpty else { showAlert("Please enter your full name."); return }
        guard !email.isEmpty else { showAlert("Please enter your email."); return }
        guard !password.isEmpty else { showAlert("Please enter your password."); return }
        guard password.count >= 6 else { showAlert("Password must be at least 6 characters."); return }

        isLoading = true
        sender.isEnabled = false

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                self.isLoading = false
                sender.isEnabled = true
                self.showAlert("Register failed: \(error.localizedDescription)")
                return
            }

            guard let uid = result?.user.uid else {
                self.isLoading = false
                sender.isEnabled = true
                self.showAlert("Register failed: missing user id.")
                return
            }

            // ✅ Firestore doc id MUST = uid (for your rules)
            let userDoc: [String: Any] = [
                "email": email,
                "fullName": fullName,
                "role": "",                 // 👈 keep empty for now (set later after role selection)
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("User").document(uid).setData(userDoc, merge: true) { err in
                self.isLoading = false
                sender.isEnabled = true

                if let err = err {
                    self.showAlert("Saved auth user, but Firestore failed: \(err.localizedDescription)")
                    return
                }

                // ✅ Next step after register:
                // Go to RoleSelection screen (recommended)
                self.goToRoleSelection()
            }
        }
    }

    private func goToRoleSelection() {
        // Change this ID to your role selection screen storyboard ID
        let sb = UIStoryboard(name: "login", bundle: nil)

        // Example identifier: "RoleSelectionViewController"
        // Put your real storyboard ID here:
        let vc = sb.instantiateViewController(withIdentifier: "RoleSelectionViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Register", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
