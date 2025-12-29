import UIKit
import FirebaseAuth

final class ResetPasswordViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // optional UX
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(email) else {
            showAlert(title: "Reset Password", message: "Please enter a valid email address.")
            return
        }

        sender.isEnabled = false

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                sender.isEnabled = true

                if let error = error {
                    self.showAlert(title: "Reset Password", message: error.localizedDescription)
                    return
                }

                // ✅ Success alert then go back to login
                let alert = UIAlertController(
                    title: "Reset Password",
                    message: "A password reset link has been sent to your email.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.goToLogin()
                })

                self.present(alert, animated: true)
            }
        }
    }

    private func goToLogin() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        let vc = sb.instantiateViewController(withIdentifier: "LoginPageController")
        // Make login the root of navigation stack (no back)
        navigationController?.setViewControllers([vc], animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        // simple validation
        return email.contains("@") && email.contains(".") && email.count >= 6
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
