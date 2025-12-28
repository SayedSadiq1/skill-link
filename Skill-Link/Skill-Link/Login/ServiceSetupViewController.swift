import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ServiceSetupViewController: BaseViewController {

    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!

    

    private let db = Firestore.firestore()
    private var isSaving = false

    override func viewDidLoad() {
        super.viewDidLoad()
        fromPicker.datePickerMode = .time
        toPicker.datePickerMode = .time
        
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard let user = Auth.auth().currentUser else {
            showSimpleAlert(title: "Error", message: "No logged in user found. Please register again.")
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
            "email": user.email ?? "",
            "serviceName": serviceName,
            "location": location,
            "fromTime": fromTime,
            "toTime": toTime,
            "profileCompleted": false
        ]

        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isSaving = false
                sender.isEnabled = true

                if let error = error {
                    self.showSimpleAlert(title: "Error", message: "Failed saving service info: \(error.localizedDescription)")
                    return
                }

              
            }
        }
    }

    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
