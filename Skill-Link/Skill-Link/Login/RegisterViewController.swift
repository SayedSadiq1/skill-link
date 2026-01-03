import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles user registration flow
final class RegisterViewController: BaseViewController {

   
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // Firestore reference
    private let db = Firestore.firestore()

    // Used to block double submit
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Runs when continue button is pressed
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isLoading else { return }

        let fullName = (fullNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic input checks
        guard !fullName.isEmpty else { showAlert("Please enter your full name."); return }
        guard !email.isEmpty else { showAlert("Please enter your email."); return }
        guard !password.isEmpty else { showAlert("Please enter your password."); return }
        guard password.count >= 6 else { showAlert("Password must be at least 6 characters."); return }

        isLoading = true
        sender.isEnabled = false

        // Create account using firebase auth
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

            // Build user document for firestore
            let userDoc: [String: Any] = [
                "email": email,
                "fullName": fullName,
                "role": "",
                "profileCompleted": false,
                "isSuspended": false,
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("User").document(uid).setData(userDoc, merge: true) { err in
                self.isLoading = false
                sender.isEnabled = true

                if let err = err {
                    self.showAlert("Saved auth user, but Firestore failed: \(err.localizedDescription)")
                    return
                }

                // Create local profile copy
                let localProfile = UserProfile(
                    id: uid,
                    fullName: fullName,
                    contact: email,
                    imageURL: nil,
                    role: .seeker,
                    skills: [],
                    brief: "",
                    isSuspended: false
                )

                // Save profile locally
                LocalUserStore.saveProfile(localProfile)
                LoginPageController.loggedinUser = localProfile

                // Go to role selection screen
                self.goToRoleSelection()
            }
        }
    }

    // Move user to role selection
    private func goToRoleSelection() {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RoleSelectionViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // Shows simple alert popup
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Register", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
