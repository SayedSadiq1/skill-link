import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AdminLoginViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private let db = Firestore.firestore()

    // The admin's email for login verification.
    private let adminEmail = "admin@skilllink.com"

    @IBAction func loginTapped(_ sender: UIButton) {
        // Retrieve and clean the email and password input from the text fields
        let email = (emailTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()  // Make email lowercase to avoid case sensitivity issues

        let password = passwordTextField.text ?? ""

        // Ensure email and password are not empty
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing", message: "Please enter email and password.")
            return
        }

        // Check if the entered email matches the pre-defined admin email
        // This is an extra layer of protection for the admin login
        guard email == adminEmail else {
            showAlert(title: "Not Allowed", message: "This login is for Admin only.")
            return
        }

        // Disable the login button to prevent multiple clicks during the login process
        sender.isEnabled = false

        // Attempt to sign in with the provided email and password using Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            DispatchQueue.main.async { sender.isEnabled = true }  // Re-enable the button after the process completes

            if let error = error {
                // Handle any errors that occur during login
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            // Retrieve the user ID (UID) from the Firebase result
            guard let uid = result?.user.uid else {
                self.showAlert(title: "Login Failed", message: "Could not get user id.")
                return
            }

            // Check the user's role in Firestore to verify they are an admin
            self.checkAdminRoleAndRoute(uid: uid)
        }
    }

    private func checkAdminRoleAndRoute(uid: String) {
        // Fetch the user's document from the Firestore "User" collection using the UID
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                // Handle any errors during Firestore document retrieval
                self.showAlert(title: "Error", message: error.localizedDescription)
                try? Auth.auth().signOut()  // Sign out the user if an error occurs
                return
            }

            // If the user document does not exist, show an access denied alert
            guard let data = snap?.data() else {
                self.showAlert(title: "Access Denied", message: "Admin profile not found.")
                try? Auth.auth().signOut()  // Sign out the user if no profile is found
                return
            }

            // Retrieve and validate the user's role from the document
            let role = (data["role"] as? String ?? "").lowercased()

            // If the role is not "admin", deny access and sign the user out
            guard role == "admin" else {
                self.showAlert(title: "Access Denied", message: "You are not an admin.")
                try? Auth.auth().signOut()
                return
            }

            // If the role is valid, proceed to the admin dashboard
            self.goToAdminDashboard()
        }
    }

    private func goToAdminDashboard() {
        // Navigate to the admin dashboard screen after successful login
        let sb = UIStoryboard(name: "Admin", bundle: nil)
        let dashboard = sb.instantiateViewController(withIdentifier: "adminDashBoard")
        navigationController?.setViewControllers([dashboard], animated: true)
    }

    private func showAlert(title: String, message: String) {
        // Show a simple alert with the given title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
