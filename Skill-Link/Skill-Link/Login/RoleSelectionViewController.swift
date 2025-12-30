import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RoleSelectionViewController: BaseViewController {

    private let db = Firestore.firestore() // Firestore database reference
    private var isSaving = false // Flag to prevent multiple role saving requests

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the back button and swipe gesture to prevent users from navigating away
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var shouldShowBackButton: Bool { false }


    // Action when the "Provider" button is tapped
    // Connect this action to the "Provider" button in the storyboard
    @IBAction func providerTapped(_ sender: UIButton) {
        setRole(role: "provider")  // Set the user's role to "provider"
    }

    // Action when the "Seeker" button is tapped
    // Connect this action to the "Seeker" button in the storyboard
    @IBAction func seekerTapped(_ sender: UIButton) {
        setRole(role: "seeker")  // Set the user's role to "seeker"
    }

    // Function to save the selected role in Firestore for the currently logged-in user
    private func setRole(role: String) {
        // Prevent multiple requests if the previous one is still in progress
        guard !isSaving else { return }
        
        // Check if a user is logged in; if not, prompt them to register
        guard let user = Auth.auth().currentUser else {
            showAlert("No logged-in user found. Please register again.")
            return
        }

        // Set the flag to indicate the saving process is in progress
        isSaving = true

        // Prepare the data to save in Firestore
        let data: [String: Any] = [
            "role": role,  // Set the role (either "provider" or "seeker")
            "profileCompleted": false  // Indicate the profile is not completed yet
        ]

        // Save the role data in Firestore under the current user's document
        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }

            // Reset the saving flag once the operation is complete
            self.isSaving = false

            // Handle any errors that occur during the Firestore write operation
            if let error = error {
                self.showAlert("Failed to save role: \(error.localizedDescription)")
                return
            }

            // Navigation is handled by the storyboard segue, so no further action needed here
        }
    }

    // Function to display an alert with a custom message
    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Role Selection",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
