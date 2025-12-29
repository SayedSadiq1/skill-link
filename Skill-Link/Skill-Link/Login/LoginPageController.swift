import UIKit
import FirebaseAuth
import FirebaseFirestore

final class LoginPageController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let db = Firestore.firestore()

    @IBAction func loginButtonTapped(_ sender: UIButton) {

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing", message: "Please enter email and password.")
            return
        }

        sender.isEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            DispatchQueue.main.async { sender.isEnabled = true }

            if let error = error {
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else {
                self.showAlert(title: "Login Failed", message: "Could not get user id.")
                return
            }

            self.checkUserProfileAndRoute(uid: uid)
        }
    }

    private func checkUserProfileAndRoute(uid: String) {
        // ✅ FIX: use "User" (same as your setup screens)
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            // ✅ 1) Check if user exists in Firestore
            guard let data = snap?.data() else {
                self.showAlert(title: "Profile Not Found",
                               message: "We couldn't find your profile. Please register first.")
                try? Auth.auth().signOut()
                return
            }

            // ✅ 2) Validate role then go to correct homepage
            let roleString = (data["role"] as? String ?? "").lowercased()

            if roleString == UserRole.provider.rawValue {
                self.goToProviderHome()
            } else if roleString == UserRole.seeker.rawValue {
                self.goToSeekerHome()
            } else {
                self.showAlert(title: "Missing Role",
                               message: "Your account role is missing. Please contact support or re-register.")
            }
        }
    }

    private func goToProviderHome() {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let home = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        navigationController?.setViewControllers([home], animated: true)
    }

    private func goToSeekerHome() {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let home = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        navigationController?.setViewControllers([home], animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
