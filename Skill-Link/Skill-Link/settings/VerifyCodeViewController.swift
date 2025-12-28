import UIKit

class VerifyCodeViewController: UIViewController {

    @IBOutlet weak var codeTextField: UITextField!

    // This tells Settings screen if verification succeeded
    var isVerified = false

    override func viewDidLoad() {
        super.viewDidLoad()
        codeTextField.keyboardType = .numberPad
    }

    // MARK: - Done Button
    @IBAction func doneTapped(_ sender: UIButton) {

        guard let code = codeTextField.text else { return }

        if code == "123456" { // demo code
            isVerified = true
            performSegue(withIdentifier: "unwindToSettings", sender: self)
        } else {
            showAlert()
        }
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Invalid Code",
            message: "Please enter the correct verification code.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
