import UIKit
import UserNotifications

class NotificationCenterViewController: BaseViewController {

    @IBOutlet weak var pushSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncSwitchWithSystemSettings()
    }

    // MARK: - Push Switch Action
    @IBAction func pushSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            requestPushPermission()
        } else {
            showDisableInfo()
        }
    }

    // MARK: - Request Permission
    private func requestPushPermission() {
        pushSwitch.isEnabled = false

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in

                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.pushSwitch.isEnabled = true

                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                        self.pushSwitch.setOn(true, animated: true)
                    } else {
                        self.pushSwitch.setOn(false, animated: true)
                        self.showAlert(
                            title: "Notifications Disabled",
                            message: "Please allow notifications in Settings to receive alerts."
                        )
                    }
                }
            }
    }

    // MARK: - Sync Switch State
    private func syncSwitchWithSystemSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let enabled =
                    settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional
                self?.pushSwitch.setOn(enabled, animated: false)
            }
        }
    }

    // MARK: - Disable Info
    private func showDisableInfo() {
        let alert = UIAlertController(
            title: "Turn Off Notifications",
            message: "You can disable notifications from the iPhone Settings.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.syncSwitchWithSystemSettings()
        })

        present(alert, animated: true)
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
