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
            showAlert(title: "Login", message: "Please enter email and password.")
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

            self.loadUserAndRoute(uid: uid)
        }
    }

    private func loadUserAndRoute(uid: String) {
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                self.showAlert(title: "Error", message: "User profile not found.")
                try? Auth.auth().signOut()
                self.clearLocalData()
                return
            }

            // Check if user is suspended
            let isSuspended = data["isSuspended"] as? Bool ?? false
            if isSuspended {
                self.showAlert(
                    title: "Account Suspended",
                    message: "Your account has been suspended. Please contact support."
                )

                try? Auth.auth().signOut()
                self.clearLocalData()
                return
            }

            // Save profile localy
            let profile = UserProfile(
                name: data["fullName"] as? String ?? "",
                skills: data["skills"] as? [String] ?? [],
                brief: data["brief"] as? String ?? "",
                contact: data["contact"] as? String ?? "",
                imageURL: data["imageURL"] as? String,
                id: snap?.documentID
            )
            self.saveUserProfileLocally(profile)

            // Route based on role
            let role = (data["role"] as? String ?? "").lowercased()

            if role == UserRole.provider.rawValue {
                self.goToProviderHome()
            } else if role == UserRole.seeker.rawValue {
                self.goToSeekerHome()
            } else {
                self.showAlert(
                    title: "Role Missing",
                    message: "Your account role is not set yet."
                )
            }
        }
    }

    private func saveUserProfileLocally(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }

    private func clearLocalData() {
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "userRole")
    }

    private func goToProviderHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func goToSeekerHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
