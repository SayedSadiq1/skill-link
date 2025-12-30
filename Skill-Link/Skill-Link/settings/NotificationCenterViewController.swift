import UIKit
import UserNotifications

class NotificationCenterViewController: BaseViewController {

    @IBOutlet weak var pushSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncSwitchWithSystemSettings()  // Sync the switch with current notification settings
    }

    // MARK: - Push Switch Action
    @IBAction func pushSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            // When the switch is turned ON, request permission
            requestPushPermission()
        } else {
            // If the switch is turned OFF, guide them to settings (optional)
            openNotificationSettings()
        }
    }

    // MARK: - Request Push Permission
    private func requestPushPermission() {
        // Disable the switch while the permission is being requested
        pushSwitch.isEnabled = false

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Enable the switch back once the request is done
                self.pushSwitch.isEnabled = true

                if granted {
                    // If permission is granted, register for remote notifications
                    UIApplication.shared.registerForRemoteNotifications()

                    // Set the switch to ON since permission is granted
                    self.pushSwitch.setOn(true, animated: true)

                    // Show alert informing user they will start receiving notifications
                    self.showNotificationEnabledAlert()
                } else {
                    // If permission is denied, set the switch to OFF
                    self.pushSwitch.setOn(false, animated: true)

                    // Show alert to guide user to enable notifications in settings
                    self.showAlertToEnableNotifications()
                }
            }
        }
    }

    // MARK: - Show Alert when Notifications are Enabled
    private func showNotificationEnabledAlert() {
        let alert = UIAlertController(
            title: "Notifications Enabled",
            message: "You will start receiving notifications from today onward.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Show the alert
        present(alert, animated: true)
    }

    // MARK: - Open Notification Settings if User Denies Permission
    private func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Alert to Enable Notifications
    private func showAlertToEnableNotifications() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please allow notifications in Settings to receive alerts.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            self.openNotificationSettings()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.pushSwitch.setOn(false, animated: true)  // Keep the switch OFF if denied
        })

        present(alert, animated: true)
    }

    // MARK: - Sync Switch State with System Settings
    private func syncSwitchWithSystemSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                // Sync the switch to match system notification settings
                let enabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                self?.pushSwitch.setOn(enabled, animated: false)
            }
        }
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
