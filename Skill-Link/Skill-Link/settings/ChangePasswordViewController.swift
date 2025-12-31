import UIKit

class ChangePasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!

    // MARK: - Eye Button for Password Visibility Toggle
    private let eyeButton = UIButton(type: .system)
    private var isPasswordVisible = false

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()   // Setup for password text fields
        setupEyeButton()    // Setup for the eye button to toggle password visibility
    }

    // MARK: - Setup TextFields
    private func setupTextFields() {
        // Initially set the password fields to secure text entry
        currentPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true

        // Set keyboard type to default (standard text input)
        currentPasswordTextField.keyboardType = .default
        newPasswordTextField.keyboardType = .default

        // Disable autocorrection and capitalization for passwords
        currentPasswordTextField.autocorrectionType = .no
        newPasswordTextField.autocorrectionType = .no

        currentPasswordTextField.autocapitalizationType = .none
        newPasswordTextField.autocapitalizationType = .none

        // Add target to detect text changes in the current password field
        currentPasswordTextField.addTarget(
            self,
            action: #selector(currentPasswordDidChange),
            for: .editingChanged
        )
    }

    // MARK: - Setup Eye Button
    private func setupEyeButton() {
        // Set the initial eye button image (eye-slash indicates password is hidden)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.isHidden = true  // Initially hide the eye button
        eyeButton.addTarget(self,
                            action: #selector(togglePasswordVisibility),
                            for: .touchUpInside)

        // Add the eye button to the right side of the current password text field
        currentPasswordTextField.rightView = eyeButton
        currentPasswordTextField.rightViewMode = .always
    }

    // MARK: - Show / Hide Eye Button Based on Password Text
    @objc private func currentPasswordDidChange() {
        // Show the eye button if there's any text in the current password field
        let hasText = !(currentPasswordTextField.text?.isEmpty ?? true)
        eyeButton.isHidden = !hasText
    }

    // MARK: - Toggle Password Visibility
    @objc private func togglePasswordVisibility() {
        // Toggle the visibility of the password and change the button image accordingly
        isPasswordVisible.toggle()

        // Retain the current first responder status (i.e., if the user is typing)
        let wasFirstResponder = currentPasswordTextField.isFirstResponder
        currentPasswordTextField.isSecureTextEntry = !isPasswordVisible

        if wasFirstResponder {
            currentPasswordTextField.becomeFirstResponder()  // Keep focus on the text field
        }

        // Update the eye button image based on password visibility
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Done Button to Submit Password Change
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        // Get text inputs from current and new password fields
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text else {
            showAlert("Error", "Please fill all fields.")
            return
        }

        // Ensure both fields are filled
        if currentPassword.isEmpty || newPassword.isEmpty {
            showAlert("Error", "All fields are required.")
            return
        }

        // Ensure new password is different from the current password
        if currentPassword == newPassword {
            showAlert(
                "Invalid Password",
                "Your new password must be different from your current password."
            )
            return
        }

        // Validate the strength of the new password
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

        // If all validations pass, show success message
        showAlert("Success", "Your password has been changed.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Password Strength Validation
    private func isValidPassword(_ password: String) -> Bool {
        // Regular expression to ensure password meets the strength requirements
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // MARK: - Alert Helper Function to Display Messages
    private func showAlert(_ title: String,
                           _ message: String,
                           completion: (() -> Void)? = nil) {

        // Create and display an alert with a title, message, and OK button
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default) { _ in
            // Execute completion closure after alert is dismissed
            completion?()
        })

        // Present the alert to the user
        present(alert, animated: true)
    }
}
