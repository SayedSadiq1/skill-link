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
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                self.showAlert(title: "Profile Not Found",
                               message: "We couldn't find your profile. Please register first.")
                try? Auth.auth().signOut()
                self.clearLocalData() // Clear any local data on failed profile retrieval
                return
            }

            // Save profile data locally
            let userProfile = UserProfile(
                name: data["name"] as? String ?? "",
                skills: data["skills"] as? [String] ?? [],
                brief: data["brief"] as? String ?? "",
                contact: data["contact"] as? String ?? "",
                imageURL: data["imageURL"] as? String,
                id: snap?.documentID
            )
            self.saveUserProfileLocally(userProfile)

            // Validate role then go to correct homepage
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

    private func saveUserProfileLocally(_ profile: UserProfile) {
        // Save the user profile to UserDefaults
        if let encodedProfile = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }

    private func loadUserProfileFromLocal() -> UserProfile? {
        // Load the user profile from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }

    private func clearLocalData() {
        // Clear the locally stored user data
        UserDefaults.standard.removeObject(forKey: "userProfile")
    }

    private func goToProviderHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let home = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        home.modalPresentationStyle = .fullScreen
        present(home, animated: true)
    }

    private func goToSeekerHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let home = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        home.modalPresentationStyle = .fullScreen
        present(home, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
