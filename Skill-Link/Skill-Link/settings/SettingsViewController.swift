import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var twoFASwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - App Permissions
    @IBAction func appPermissionsTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Two-Factor Authentication
    @IBAction func twoFASwitchChanged(_ sender: UISwitch) {

        if sender.isOn {
            // Navigate to verification screen
            performSegue(withIdentifier: "toVerifyCode", sender: self)
        } else {
            // Disable 2FA confirmation
            showDisable2FAAlert()
        }
    }

    // MARK: - Disable 2FA Alert
    private func showDisable2FAAlert() {
        let alert = UIAlertController(
            title: "Disable Two-Factor Authentication",
            message: "Are you sure you want to disable this security feature?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Disable", style: .destructive) { _ in
            self.twoFASwitch.setOn(false, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.twoFASwitch.setOn(true, animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Handle result from Verify Code screen
    @IBAction func unwindFromVerifyCode(_ segue: UIStoryboardSegue) {

        if let source = segue.source as? VerifyCodeViewController {
            if source.isVerified {
                // ✅ Code correct → keep switch ON
                twoFASwitch.setOn(true, animated: true)
            } else {
                // ❌ Code failed / cancelled → turn OFF
                twoFASwitch.setOn(false, animated: true)
            }
        }
    }
}
