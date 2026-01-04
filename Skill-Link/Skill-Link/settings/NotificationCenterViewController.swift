import UIKit
import UserNotifications

class NotificationCenterViewController: BaseViewController {

    @IBOutlet weak var pushSwitch: UISwitch!  // UISwitch to toggle push notifications

    override func viewDidLoad() {
        super.viewDidLoad()
        syncSwitchWithSystemSettings()  // Sync the switch state with the current notification settings on the device
    }

    // MARK: - Push Switch Action
    @IBAction func pushSwitchChanged(_ sender: UISwitch) {
        // If the switch is turned ON, request permission for push notifications
        if sender.isOn {
            requestPushPermission()
        } else {
            // If the switch is turned OFF, guide the user to settings to enable notifications manually
            openNotificationSettings()
        }
    }

    // MARK: - Request Push Permission
    private func requestPushPermission() {
        // Disable the switch while the permission request is being processed
        pushSwitch.isEnabled = false

        // Request permission to send notifications (alert, badge, sound)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // Re-enable the switch after the request is completed
                self.pushSwitch.isEnabled = true

                if granted {
                    // If permission is granted, register for remote notifications
                    UIApplication.shared.registerForRemoteNotifications()

                    // Set the switch to ON because the user granted permission
                    self.pushSwitch.setOn(true, animated: true)

                    // Show an alert informing the user that they will start receiving notifications
                    self.showNotificationEnabledAlert()
                } else {
                    // If permission is denied, turn off the switch
                    self.pushSwitch.setOn(false, animated: true)

                    // Show an alert to guide the user to enable notifications in settings
                    self.showAlertToEnableNotifications()
                }
            }
        }
    }

    // MARK: - Show Alert when Notifications are Enabled
    private func showNotificationEnabledAlert() {
        // Create and display an alert informing the user that notifications are enabled
        let alert = UIAlertController(
            title: "Notifications Enabled",
            message: "You will start receiving notifications from today onward.",
            preferredStyle: .alert
        )

        // Add an OK button to dismiss the alert
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Show the alert to the user
        present(alert, animated: true)
    }

    // MARK: - Open Notification Settings if User Denies Permission
    private func openNotificationSettings() {
        // Open the device's notification settings where the user can enable notifications manually
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Alert to Enable Notifications
    private func showAlertToEnableNotifications() {
        // Create an alert to prompt the user to enable notifications in their device's settings
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please allow notifications in Settings to receive alerts.",
            preferredStyle: .alert
        )

        // Add a button that opens the settings page when tapped
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            self.openNotificationSettings()
        })

        // Add a cancel button to dismiss the alert without any further action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Set the switch to OFF if the user cancels the action
            self.pushSwitch.setOn(false, animated: true)
        })

        // Show the alert to the user
        present(alert, animated: true)
    }

    // MARK: - Sync Switch State with System Settings
    private func syncSwitchWithSystemSettings() {
        // Check the current system notification settings
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                // Sync the state of the switch with the system's notification authorization status
                let enabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                self?.pushSwitch.setOn(enabled, animated: false)
            }
        }
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        // Helper function to display a simple alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
