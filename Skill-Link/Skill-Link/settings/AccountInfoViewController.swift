import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountInfoViewController: BaseViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }

    // MARK: - Load User Info
    private func loadUserInfo() {
        guard let user = Auth.auth().currentUser else {
            fullNameLabel.text = "-"
            emailLabel.text = "-"
            return
        }

        // Email from Firebase Auth
        emailLabel.text = user.email ?? "-"

        // Full name from Firestore
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
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        do {
            // Firebase sign out
            try Auth.auth().signOut()

            // ✅ Clear local profile using the new helper
            LocalUserStore.clearProfile()

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
        ) else {
            fatalError("StartPageViewController not found. Check storyboard ID.")
        }

        navigationController?.setViewControllers([startVC], animated: true)
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
