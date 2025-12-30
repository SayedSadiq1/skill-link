import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountCreatedViewController: BaseViewController {

    private let db = Firestore.firestore() // Firestore reference to access user data

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the back button and swipe-to-go-back gesture to prevent navigating back
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var shouldShowBackButton: Bool { false }


    // Hide the back button and disable swipe-to-go-back for this screen
    private func hideBackButton() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        // Check if the current user is logged in
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert("No user session. Please login again.") // Show alert if no user is logged in
            return
        }

        // Fetch user data from Firestore using the user ID (uid)
        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            // Handle any errors during Firestore document retrieval
            if let err = err {
                self.showAlert("Failed reading role: \(err.localizedDescription)") // Show error if fetching user data fails
                return
            }

            // Retrieve the role from the Firestore document
            let role = (snap?.data()?["role"] as? String ?? "").lowercased()

            // Get the storyboard reference to navigate to the correct screen based on role
            let sb = UIStoryboard(name: "login", bundle: nil)

            // Navigate to the appropriate screen based on the user's role
            if role == "provider" {
                // If the role is "provider", navigate to the provider setup/profile screen
                let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController1")
                self.navigationController?.pushViewController(vc, animated: true)
            } else if role == "seeker" {
                // If the role is "seeker", navigate to the seeker profile setup screen
                let vc = sb.instantiateViewController(withIdentifier: "SetupProfileSeekerViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // If the role is missing, show an error and prompt the user to select a role again
                self.showAlert("Role is missing. Please select role again.")
            }
        }
    }

    // Function to display an alert with the provided message
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Account Created", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default)) // Add an "OK" button to dismiss the alert
        present(alert, animated: true)
    }
}
