import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SettingsViewController: BaseViewController {

    private let db = Firestore.firestore()

    // MARK: - Data Sharing Preferences Switch
    @IBOutlet weak var dataSharingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncDataSharingSwitchState()
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

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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

        // 1. Delete Firestore user document
        db.collection("User").document(uid).delete { [weak self] error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            // 2. Delete Firebase Auth account
            user.delete { authError in
                if let authError = authError {
                    self.showAlert(
                        title: "Error",
                        message: "Please re-login before deleting your account. \(authError.localizedDescription)"
                    )
                    return
                }

                // 3. Clear local data
                self.clearLocalUserData()

                // 4. Go to start page
                self.goToStartPage()
            }
        }
    }

    // MARK: - Clear Local Data
    private func clearLocalUserData() {
        // ✅ Use the centralized local store
        LocalUserStore.clearProfile()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Navigation
    private func goToStartPage() {
        let sb = UIStoryboard(name: "login", bundle: nil)

//        guard let startVC = sb.instantiateViewController(
//            withIdentifier: "StartPageViewController"
//        ) else {
//            fatalError("StartPageViewController not found. Check storyboard ID.")
//        }
//
//        navigationController?.setViewControllers([startVC], animated: true)
    }

    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Data Sharing
    @IBAction func dataSharingSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "dataSharingEnabled")

        showAlert(
            title: sender.isOn ? "Data Sharing Enabled" : "Data Sharing Disabled",
            message: sender.isOn
                ? "Your data may be used for internal analytics."
                : "Your data will not be shared."
        )
    }

    private func syncDataSharingSwitchState() {
        let enabled = UserDefaults.standard.bool(forKey: "dataSharingEnabled")
        dataSharingSwitch.setOn(enabled, animated: false)
    }
}
