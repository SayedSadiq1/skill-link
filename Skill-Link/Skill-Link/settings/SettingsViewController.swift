import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SettingsViewController: BaseViewController {

    private let db = Firestore.firestore()  // Firestore instance to interact with Firebase database

    // MARK: - Data Sharing Preferences Switch
    @IBOutlet weak var dataSharingSwitch: UISwitch!  // Switch to toggle data sharing preferences

    override func viewDidLoad() {
        super.viewDidLoad()
        // Sync the data sharing switch with the stored preference in UserDefaults when the view loads
        syncDataSharingSwitchState()
    }

    // MARK: - App Permissions
    @IBAction func appPermissionsTapped(_ sender: UIButton) {
        // Open device settings where the user can change app-specific permissions
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Delete Account
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        // Show a confirmation alert to ensure the user wants to delete their account
        showDeleteAccountConfirmation()
    }

    private func showDeleteAccountConfirmation() {
        // Create a confirmation alert before deleting the account
        let alert = UIAlertController(
            title: "Delete Account",
            message: "This will permanently delete your account. This action cannot be undone.",
            preferredStyle: .alert
        )

        // Add a Cancel action to dismiss the alert
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Add a Delete action to confirm account deletion
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAccountCompletely()
        })

        // Present the confirmation alert
        present(alert, animated: true)
    }

    private func deleteAccountCompletely() {
        // Ensure the current user is authenticated before proceeding
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not found. Please login again.")
            return
        }

        let uid = user.uid

        // Step 1: Delete user data from Firestore
        db.collection("User").document(uid).delete { [weak self] error in
            guard let self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: "Failed to delete user data. \(error.localizedDescription)")
                return
            }

            // Step 2: Delete user from Firebase Auth
            user.delete { authError in
                if let authError = authError {
                    self.showAlert(
                        title: "Error",
                        message: "Please re-login before deleting your account. \(authError.localizedDescription)"
                    )
                    return
                }

                // Step 3: Clear local user data
                self.clearLocalUserData()

                // Step 4: Navigate back to the start page
                self.goToStartPage()
            }
        }
    }

    // MARK: - Clear Local Data
    private func clearLocalUserData() {
        // Remove locally saved user profile from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userProfile")

        // Clear any cached data in the app
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Navigation
    private func goToStartPage() {
        // Load the start page view controller from the storyboard
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let startVC = sb.instantiateViewController(
            withIdentifier: "StartPageViewController"
        ) as? UIViewController else {
            fatalError("StartPageViewController not found. Check storyboard ID.")
        }

        // Reset the navigation stack so the user can't go back to the previous screens
        navigationController?.setViewControllers([startVC], animated: true)
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        // Helper function to show an alert with a title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Data Sharing Switch Action
    @IBAction func dataSharingSwitchChanged(_ sender: UISwitch) {
        // Check if the switch is ON or OFF and enable/disable data sharing accordingly
        if sender.isOn {
            enableDataSharing()
        } else {
            disableDataSharing()
        }
    }

    // MARK: - Enable Data Sharing
    private func enableDataSharing() {
        // Store the user's preference to enable data sharing in UserDefaults
        UserDefaults.standard.set(true, forKey: "dataSharingEnabled")
        
        // Show an alert confirming that data sharing is enabled
        showAlert(title: "Data Sharing Enabled", message: "Your data will be used for internal analytics and may be shared with third parties.")
    }

    // MARK: - Disable Data Sharing
    private func disableDataSharing() {
        // Store the user's preference to disable data sharing in UserDefaults
        UserDefaults.standard.set(false, forKey: "dataSharingEnabled")
        
        // Show an alert confirming that data sharing is disabled
        showAlert(title: "Data Sharing Disabled", message: "Your data will no longer be shared for analytics or with third parties.")
    }

    // MARK: - Sync Data Sharing Switch State
    private func syncDataSharingSwitchState() {
        // Retrieve the stored data sharing preference from UserDefaults and update the switch state accordingly
        let isDataSharingEnabled = UserDefaults.standard.bool(forKey: "dataSharingEnabled")
        dataSharingSwitch.setOn(isDataSharingEnabled, animated: false)
    }
}
