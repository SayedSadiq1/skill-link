import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ServiceSetupViewController: BaseViewController {

    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!

    private let db = Firestore.firestore()  // Firestore reference to save the service data.
    private var isSaving = false  // Flag to prevent multiple save operations

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the date pickers to only show time
        fromPicker.datePickerMode = .time
        toPicker.datePickerMode = .time
        
        // Disable the back button and swipe gesture to prevent navigating back
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override var shouldShowBackButton: Bool { false }
    
  


    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }

        // try local user first (main source)
        guard let uid = LocalUserStore.currentUserId() ?? Auth.auth().currentUser?.uid else {
            showSimpleAlert(title: "Error", message: "You are not logged-in. Please login again.")
            return
        }

        let serviceName = serviceNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !serviceName.isEmpty else {
            showSimpleAlert(title: "Missing", message: "Please enter service name.")
            return
        }

        guard !location.isEmpty else {
            showSimpleAlert(title: "Missing", message: "Please enter location.")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let fromTime = formatter.string(from: fromPicker.date)
        let toTime = formatter.string(from: toPicker.date)

        isSaving = true
        sender.isEnabled = false

        let data: [String: Any] = [
            "serviceName": serviceName,
            "location": location,
            "fromTime": fromTime,
            "toTime": toTime,
            "profileCompleted": false
        ]

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isSaving = false
                sender.isEnabled = true

                if let error = error {
                    self.showSimpleAlert(title: "Error", message: "Failed saving service info: \(error.localizedDescription)")
                    return
                }

                // next navigation step happens after this screen
            }
        }
    }


    private func showSimpleAlert(title: String, message: String) {
        // Simple function to show an alert with a custom title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
