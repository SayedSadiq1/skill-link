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

        // Email (Auth is safest)
        emailLabel.text = user.email ?? "-"

        // Full name from Firestore
        db.collection("User").document(user.uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let data = snap?.data() {
                let name = data["fullName"] as? String ?? "-"
                DispatchQueue.main.async {
                    self.fullNameLabel.text = name
                }
            } else {
                DispatchQueue.main.async {
                    self.fullNameLabel.text = "-"
                }
            }
        }
    }

    // MARK: - Sign Out
    @IBAction func signOutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            goToStartPage()
        } catch {
            showAlert(title: "Error", message: "Failed to sign out. Please try again.")
        }
    }

    // MARK: - Navigation
    private func goToStartPage() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let startVC = sb.instantiateViewController(withIdentifier: "StartPage") as? UIViewController else {
            fatalError("❌ StartPage not found. Check storyboard ID.")
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
