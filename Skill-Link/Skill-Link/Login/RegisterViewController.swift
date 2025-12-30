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

            // Save user data to Firestore
            let userDoc: [String: Any] = [
                "email": email,
                "fullName": fullName,
                "role": "",                 // Empty for now, will be set after role selection
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("User").document(uid).setData(userDoc, merge: true) { err in
                self.isLoading = false
                sender.isEnabled = true

                if let err = err {
                    self.showAlert("Saved auth user, but Firestore failed: \(err.localizedDescription)")
                    return
                }

                // Save profile locally
                let userProfile = UserProfile(
                    name: fullName,
                    skills: [], // No skills on registration, can update later
                    brief: "",   // Empty brief for now
                    contact: email,
                    imageURL: nil,
                    id: uid
                )
                self.saveUserProfileLocally(userProfile)

                // Navigate to RoleSelection screen
                self.goToRoleSelection()
            }
        }
    }

    private func saveUserProfileLocally(_ profile: UserProfile) {
        // Save the user profile to UserDefaults
        if let encodedProfile = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }

    private func goToRoleSelection() {
        // Navigate to RoleSelection screen
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RoleSelectionViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Register", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
