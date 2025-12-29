import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AdminLoginViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let db = Firestore.firestore()

    // optional extra protection (your shared admin email)
    private let adminEmail = "admin@skilllink.com"

    @IBAction func loginTapped(_ sender: UIButton) {

        let email = (emailTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let password = passwordTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing", message: "Please enter email and password.")
            return
        }

        // ✅ Optional: only allow this exact email to even try admin login
        guard email == adminEmail else {
            showAlert(title: "Not Allowed", message: "This login is for Admin only.")
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

            // ✅ Check role in Firestore
            self.checkAdminRoleAndRoute(uid: uid)
        }
    }

    private func checkAdminRoleAndRoute(uid: String) {
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                try? Auth.auth().signOut()
                return
            }

            guard let data = snap?.data() else {
                self.showAlert(title: "Access Denied", message: "Admin profile not found.")
                try? Auth.auth().signOut()
                return
            }

            let role = (data["role"] as? String ?? "").lowercased()

            guard role == "admin" else {
                self.showAlert(title: "Access Denied", message: "You are not an admin.")
                try? Auth.auth().signOut()
                return
            }

            self.goToAdminDashboard()
        }
    }

    private func goToAdminDashboard() {
        let sb = UIStoryboard(name: "Admin", bundle: nil)
        let dashboard = sb.instantiateViewController(withIdentifier: "Admin DashBoard")
        navigationController?.setViewControllers([dashboard], animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
