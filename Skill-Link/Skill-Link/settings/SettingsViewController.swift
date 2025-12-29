import UIKit

class SettingsViewController: BaseViewController {

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
            message: "This will permanently remove your account from this device. This action cannot be undone.",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
        }

        present(alert, animated: true)
    }

    private func deleteAccount() {
        // If you have no backend, this can be "true" directly.
        deleteAccountFromServer { [weak self] success in
            DispatchQueue.main.async {
                guard let self else { return }

                if success {
                    self.clearLocalUserData()
                    self.goToLoginScreen()
                } else {
                    self.showAlert(title: "Error", message: "Failed to delete account. Please try again.")
                }
            }
        }
    }

    // MARK: - Mock delete (replace with real API if needed)
    private func deleteAccountFromServer(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }

    // MARK: - Clear Local Data
    private func clearLocalUserData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "authToken")
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "isLoggedIn")
        defaults.synchronize()

        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Go to Login
    private func goToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: loginVC)
            window.makeKeyAndVisible()
        } else {
            navigationController?.setViewControllers([loginVC], animated: true)
        }
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
