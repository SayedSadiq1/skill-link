import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ServiceSetupViewController: BaseViewController {

    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!

    private let db = Firestore.firestore()  // Firestore reference to save the service data
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
        // Prevent multiple taps during the save process
        guard !isSaving else { return }
        
        // Ensure the user is logged in
        guard let user = Auth.auth().currentUser else {
            showSimpleAlert(title: "Error", message: "No logged in user found. Please register again.")
            return
        }

        // Retrieve and clean the input data from the text fields
        let serviceName = serviceNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Check if the service name and location fields are filled
        guard !serviceName.isEmpty else {
            showSimpleAlert(title: "Missing", message: "Please enter service name.")
            return
        }

        guard !location.isEmpty else {
            showSimpleAlert(title: "Missing", message: "Please enter location.")
            return
        }

        // Format the time selected in the date pickers to the desired format
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"  // Example format: 10:00 AM

        let fromTime = formatter.string(from: fromPicker.date)
        let toTime = formatter.string(from: toPicker.date)

        // Set the flag to indicate that saving is in progress
        isSaving = true
        sender.isEnabled = false  // Disable the button to prevent multiple submissions

        // Prepare the data to be saved to Firestore
        let data: [String: Any] = [
            "email": user.email ?? "",  // Store the user's email
            "serviceName": serviceName,  // Store the service name
            "location": location,  // Store the service location
            "fromTime": fromTime,  // Store the start time of service
            "toTime": toTime,  // Store the end time of service
            "profileCompleted": false  // Mark the profile as incomplete until further setup
        ]

        // Save the data to the Firestore "User" collection, using the logged-in user's UID
        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                // Re-enable the button and reset the saving flag after operation completes
                self.isSaving = false
                sender.isEnabled = true

                // Handle any errors that occur while saving the data
                if let error = error {
                    self.showSimpleAlert(title: "Error", message: "Failed saving service info: \(error.localizedDescription)")
                    return
                }

                // You could add navigation or further steps here if needed
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
