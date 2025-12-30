import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SetupProfileProviderViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var fullNameLabel: UILabel!

    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!

    @IBOutlet weak var profileImageView: UIImageView!

    private let db = Firestore.firestore()  // Firestore reference for saving data
    private var photoPicker: PhotoPickerHelper?  // Helper for picking a photo
    private var selectedImage: UIImage?  // Selected profile image
    private var isSaving = false  // Flag to prevent multiple save operations

    private var loadedFullName: String = ""  // Full name loaded from Firestore

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the back button and swipe gesture to navigate back
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Set default image if no image is selected
        if profileImageView.image == nil {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        // Enable user interaction and add gesture recognizer for image tapping
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Configure appearance of the brief container and text view
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        // Configure text view's appearance
        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        briefTextView.delegate = self  // Set self as the delegate for text view
        setBriefPlaceholderIfNeeded()  // Set placeholder text if needed

        loadFullNameFromFirestore()  // Load the user's full name from Firestore
    }
    
    override var shouldShowBackButton: Bool { false }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make the profile image a circle
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    // Load the full name from Firestore and display it
    private func loadFullNameFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            fullNameLabel.text = "No user"
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            // Handle any error in fetching user data
            DispatchQueue.main.async {
                if let err = err {
                    self.fullNameLabel.text = "Error loading name"
                    print("Error loading name: \(err.localizedDescription)")
                    return
                }

                // Retrieve the full name from the Firestore data
                let data = snap?.data() ?? [:]
                let name = (data["fullName"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                self.loadedFullName = name
                self.fullNameLabel.text = name.isEmpty ? "Name not set" : name

                // Save the full name locally after loading it from Firestore
                self.saveUserProfileLocally()
            }
        }
    }

    // Save user profile data locally using UserDefaults
    private func saveUserProfileLocally() {
        let userProfile = UserProfile(
            name: loadedFullName,
            skills: [],
            brief: briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            contact: contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            imageURL: nil,  // Image URL will be saved if image is uploaded
            id: Auth.auth().currentUser?.uid
        )

        // Encode and save the profile to UserDefaults
        if let encodedProfile = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }

    // Set the placeholder text for the brief text view if it's empty
    private func setBriefPlaceholderIfNeeded() {
        if briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            briefTextView.text = "Brief..."
            briefTextView.textColor = .systemGray3
        }
    }

    // When editing starts in the brief text view, remove placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray3 {
            textView.text = ""
            textView.textColor = .label
        }
    }

    // When editing ends in the brief text view, restore placeholder text if needed
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setBriefPlaceholderIfNeeded()
        }
    }

    // MARK: - Continue Button Action
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }  // Prevent saving if already in progress
        guard validateRequiredFields() else { return }  // Validate the required fields
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(message: "No logged-in user found.")  // Show error if no user is logged in
            return
        }

        isSaving = true
        sender.isEnabled = false
        showSavingHUD(true)  // Show loading indicator while saving data

        // If a photo is selected, upload it; otherwise, save the profile without an image
        if let image = selectedImage {
            CloudinaryUploader.shared.uploadImage(image) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self.saveProviderProfile(uid: uid, imageURL: url, sender: sender)
                    case .failure(let error):
                        self.finishSaving(sender: sender)
                        self.showAlert(message: "Failed to upload image:\n\(error.localizedDescription)")
                    }
                }
            }
        } else {
            // No image selected, save profile without image URL
            self.saveProviderProfile(uid: uid, imageURL: nil, sender: sender)
        }
    }

    // Save the provider profile data to Firestore
    private func saveProviderProfile(uid: String, imageURL: String?, sender: UIButton) {
        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let briefFinal: String =
            (briefTextView.textColor == .systemGray3)
            ? ""
            : briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        var data: [String: Any] = [
            "fullName": loadedFullName,
            "skills": skillsArray,
            "contact": contact,
            "brief": briefFinal,
            "role": "provider",
            "profileCompleted": true
        ]

        if let imageURL = imageURL {
            data["imageURL"] = imageURL  // Add image URL if available
        }

        // Save the data to the user's Firestore document
        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }
            DispatchQueue.main.async {
                if let err = err {
                    self.finishSaving(sender: sender)
                    self.showAlert(message: "Failed to save profile:\n\(err.localizedDescription)")
                    return
                }

                // Dismiss the saving HUD, then navigate to the provider profile screen
                self.finishSaving(sender: sender) {
                    self.goToProfileProvider()
                }
            }
        }
    }

    // Navigate to the provider profile screen after saving the data
    private func goToProfileProvider() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController") as? ProfileProviderViewController else {
            fatalError("Could not find ProfileProviderViewController in storyboard.")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // Validate that all required fields are filled correctly
    private func validateRequiredFields() -> Bool {
        if loadedFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(message: "Your name is missing in Firebase. Go back and register again.")
            return false
        }

        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if skillsArray.isEmpty {
            showAlert(message: "Please enter at least one skill.")
            return false
        }

        if skillsArray.count > 3 {
            showAlert(message: "You can enter a maximum of 3 skills only.")
            return false
        }

        if contact.isEmpty {
            showAlert(message: "Please enter your contact information.")
            return false
        }

        return true
    }

    // Show an alert with a custom message
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Setup Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Saving HUD
    private var savingAlert: UIAlertController?

    private func showSavingHUD(_ show: Bool) {
        if show {
            let alert = UIAlertController(title: nil, message: "Saving...", preferredStyle: .alert)
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            alert.view.addSubview(spinner)

            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                spinner.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
            ])

            savingAlert = alert
            present(alert, animated: true)
        } else {
            savingAlert?.dismiss(animated: true)
            savingAlert = nil
        }
    }

    // Dismiss the saving alert and handle completion
    private func finishSaving(sender: UIButton, completion: (() -> Void)? = nil) {
        savingAlert?.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.savingAlert = nil
            self.isSaving = false
            sender.isEnabled = true
            completion?()
        }
    }

    // MARK: - Photo picking
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImage = image
        }
        photoPicker?.presentPicker()
    }
}
