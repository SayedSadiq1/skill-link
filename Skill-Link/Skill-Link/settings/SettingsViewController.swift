import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SettingsViewController: BaseViewController {

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - App Permissions
    @IBAction func appPermissionsTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Delete Account
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        showDeleteAccountConfirmation()
    }

    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account. This action cannot be undone.",
            preferredStyle: .alert
        )

        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Confirm delete
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAccountCompletely()
        })

        present(alert, animated: true)
    }

    private func deleteAccountCompletely() {
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not found. Please login again.")
            return
        }

        let uid = user.uid

        // Step 1: delete user data from Firestore
        db.collection("User").document(uid).delete { [weak self] error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: "Failed to delete user data. \(error.localizedDescription)")
                return
            }

            // Step 2: delete user from Firebase Auth
            user.delete { authError in
                if let authError = authError {
                    self.showAlert(
                        title: "Error",
                        message: "Please re-login before deleting your account. \(authError.localizedDescription)"
                    )
                    return
                }

                // Step 3: clear local data
                self.clearLocalUserData()

                // Step 4: go back to start page
                self.goToStartPage()
            }
        }
    }

    // MARK: - Clear Local Data
    private func clearLocalUserData() {
        // Remove locally saved user profile
        UserDefaults.standard.removeObject(forKey: "userProfile")

        // Remove any cached data
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Navigation
    private func goToStartPage() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let startVC = sb.instantiateViewController(
            withIdentifier: "StartPageViewController"
        ) as? UIViewController else {
            fatalError("StartPageViewController not found. Check storyboard ID.")
        }

        // Reset navigation stack so user cant go back
        navigationController?.setViewControllers([startVC], animated: true)
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
