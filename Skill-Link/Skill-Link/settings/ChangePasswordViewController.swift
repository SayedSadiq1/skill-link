import UIKit

class ChangePasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!

    // MARK: - Eye Button
    private let eyeButton = UIButton(type: .system)
    private var isPasswordVisible = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupEyeButton()
    }

    // MARK: - Setup TextFields
    private func setupTextFields() {
        currentPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true

        currentPasswordTextField.keyboardType = .default
        newPasswordTextField.keyboardType = .default

        currentPasswordTextField.autocorrectionType = .no
        newPasswordTextField.autocorrectionType = .no

        currentPasswordTextField.autocapitalizationType = .none
        newPasswordTextField.autocapitalizationType = .none

        currentPasswordTextField.addTarget(
            self,
            action: #selector(currentPasswordDidChange),
            for: .editingChanged
        )
    }

    // MARK: - Eye Button Setup
    private func setupEyeButton() {
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.isHidden = true
        eyeButton.addTarget(self,
                            action: #selector(togglePasswordVisibility),
                            for: .touchUpInside)

        currentPasswordTextField.rightView = eyeButton
        currentPasswordTextField.rightViewMode = .always
    }

    // MARK: - Show / Hide Eye
    @objc private func currentPasswordDidChange() {
        let hasText = !(currentPasswordTextField.text?.isEmpty ?? true)
        eyeButton.isHidden = !hasText
    }

    // MARK: - Toggle Password Visibility
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()

        let wasFirstResponder = currentPasswordTextField.isFirstResponder
        currentPasswordTextField.isSecureTextEntry = !isPasswordVisible

        if wasFirstResponder {
            currentPasswordTextField.becomeFirstResponder()
        }

        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Done Button
    @IBAction func doneButtonTapped(_ sender: UIButton) {

        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text else {
            showAlert("Error", "Please fill all fields.")
            return
        }

        if currentPassword.isEmpty || newPassword.isEmpty {
            showAlert("Error", "All fields are required.")
            return
        }

        // ❌ New password must NOT equal current password
        if currentPassword == newPassword {
            showAlert(
                "Invalid Password",
                "Your new password must be different from your current password."
            )
            return
        }

        // ❌ Strong password validation
        if !isValidPassword(newPassword) {
            showAlert(
                "Invalid Password",
                """
                Password must contain:
                • At least 8 characters
                • At least one uppercase letter
                • At least one lowercase letter
                • At least one number
                • At least one special character(e.g. ! @ # $ %) 
                """

            )
            return
        }

        // ✅ SUCCESS
        showAlert("Success", "Your password has been changed.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Password Validation
    private func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // MARK: - Alert Helper
    private func showAlert(_ title: String,
                           _ message: String,
                           completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default) { _ in
            completion?()
        })

        present(alert, animated: true)
    }
}
