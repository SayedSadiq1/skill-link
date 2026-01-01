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
        // nothing special here, just wait for user input
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        // stop double taps while register is running
        guard !isLoading else { return }

        let fullName = (fullNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // basic checks before we hit firebase
        guard !fullName.isEmpty else { showAlert("Please enter your full name."); return }
        guard !email.isEmpty else { showAlert("Please enter your email."); return }
        guard !password.isEmpty else { showAlert("Please enter your password."); return }
        guard password.count >= 6 else { showAlert("Password must be at least 6 characters."); return }

        isLoading = true
        sender.isEnabled = false

        // create user in Firebase Auth first
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

            // save basic user document in firestore
            let userDoc: [String: Any] = [
                "email": email,
                "fullName": fullName,
                "role": "",                    // will be set in role selection
                "profileCompleted": false,     // still not done yet
                "isSuspended": false,          // default is active user
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("User").document(uid).setData(userDoc, merge: true) { err in
                self.isLoading = false
                sender.isEnabled = true

                if let err = err {
                    self.showAlert("Saved auth user, but Firestore failed: \(err.localizedDescription)")
                    return
                }

                // save local profile so we always know who is logged in
                let localProfile = UserProfile(
                    name: fullName,
                    skills: [],
                    brief: "",
                    contact: email,
                    imageURL: nil,
                    id: uid
                )
                LocalUserStore.saveProfile(localProfile)

                // go pick role next
                self.goToRoleSelection()
            }
        }
    }

    private func goToRoleSelection() {
        // move to role selection screen
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RoleSelectionViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(_ message: String) {
        // quick alert helper for this screen
        let alert = UIAlertController(title: "Register", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
