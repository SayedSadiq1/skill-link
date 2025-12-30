import UIKit
import FirebaseAuth

final class ResetPasswordViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Optional UX enhancements for email input field
        emailTextField.keyboardType = .emailAddress  // Set the keyboard type to email address
        emailTextField.autocapitalizationType = .none // Disable auto-capitalization
        emailTextField.autocorrectionType = .no      // Disable autocorrection
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        // Retrieve and clean the email input
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate that the email address is in a correct format
        guard isValidEmail(email) else {
            // Show an alert if the email is invalid
            showAlert(title: "Reset Password", message: "Please enter a valid email address.")
            return
        }

        // Disable the button to prevent multiple clicks during the process
        sender.isEnabled = false

        // Request Firebase to send a password reset email
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self else { return }

            DispatchQueue.main.async {
                // Re-enable the button after the process is complete
                sender.isEnabled = true

                if let error = error {
                    // Show an error alert if sending the reset link fails
                    self.showAlert(title: "Reset Password", message: error.localizedDescription)
                    return
                }

                // Show a success alert, then navigate to the login page
                let alert = UIAlertController(
                    title: "Reset Password",
                    message: "A password reset link has been sent to your email.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.goToLogin()  // Navigate to the login screen after successful reset request
                })

                self.present(alert, animated: true)
            }
        }
    }

    private func goToLogin() {
        // Navigate to the login page after password reset success
        let sb = UIStoryboard(name: "login", bundle: nil)

        let vc = sb.instantiateViewController(withIdentifier: "LoginPageController")
        // Set the login screen as the root view controller, preventing back navigation
        navigationController?.setViewControllers([vc], animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        // Basic validation for email format
        return email.contains("@") && email.contains(".") && email.count >= 6
    }

    private func showAlert(title: String, message: String) {
        // Display a simple alert with the provided title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
