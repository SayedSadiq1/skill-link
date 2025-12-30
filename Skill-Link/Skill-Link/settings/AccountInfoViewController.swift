import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountInfoViewController: BaseViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load user info when the screen opens
        loadUserInfo()
    }

    // MARK: - Load User Info
    private func loadUserInfo() {
        guard let user = Auth.auth().currentUser else {
            fullNameLabel.text = "-"
            emailLabel.text = "-"
            return
        }

        // Email is taken from Firebase Auth (more reliable)
        emailLabel.text = user.email ?? "-"

        // Full name is loaded from Firestore
        db.collection("User").document(user.uid).getDocument { [weak self] snap, _ in
            guard let self else { return }

            let name = snap?.data()?["fullName"] as? String ?? "-"

            DispatchQueue.main.async {
                self.fullNameLabel.text = name
            }
        }
    }

    // MARK: - Sign Out
    @IBAction func signOutTapped(_ sender: UIButton) {
        // Ask user to confirm sign out
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        // Cancel button (do nothing)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Confirm sign out
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()

            // Clear locally saved user profile
            UserDefaults.standard.removeObject(forKey: "userProfile")

            // Go back to the start page
            goToStartPage()

        } catch {
            showAlert(title: "Error", message: "Failed to sign out. Please try again.")
        }
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

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
