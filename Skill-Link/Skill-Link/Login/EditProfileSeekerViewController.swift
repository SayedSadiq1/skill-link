import UIKit
import FirebaseAuth
import FirebaseFirestore

final class EditProfileSeekerViewController: BaseViewController {

    // Text fields for user input
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!

    // Profile image view
    @IBOutlet weak var profileImageView: UIImageView!

    var profile: SeekerProfile?  // Seeker profile passed from ProfileSeekerViewController
    var onSave: ((SeekerProfile) -> Void)?  // Callback to notify the parent controller after save

    private let db = Firestore.firestore()  // Firestore reference for saving profile data
    private var photoPicker: PhotoPickerHelper?  // Helper for selecting photos

    // Cloudinary credentials for image upload
    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned"

    // Variables for image upload
    private var selectedImageData: Data?  // Data for selected image
    private var selectedImageURL: String?  // URL for the uploaded image

    private var isSaving = false  // Flag to prevent multiple save attempts

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style the text fields for input
        styleTextField(nameTextField)
        styleTextField(interestsTextField)
        styleTextField(contactTextField)

        // Enable image tapping to change photo
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        guard let profile = profile else {
            print("❌ EditProfileSeekerViewController: profile is nil (not passed)")
            return
        }

        // Pre-fill the text fields with the existing profile data
        nameTextField.text = profile.name
        interestsTextField.text = profile.interests.joined(separator: ", ")
        contactTextField.text = profile.contact

        // Load the image if it exists in the profile
        selectedImageURL = profile.imageURL
        if let urlString = profile.imageURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make the profile image circular
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Styling the text fields
    private func styleTextField(_ tf: UITextField) {
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .white

        // Add padding to the left of text fields
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = padding
        tf.leftViewMode = .always
    }

    // MARK: - Photo picker action
    @objc private func changePhotoTapped() {
        // Initialize the photo picker helper
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()  // Present the photo picker
    }

    // MARK: - Save button action
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaving else { return }  // Prevent multiple save attempts
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "No logged in user. Please login again.")
            return
        }

        // Retrieve and clean user inputs
        let fullName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Validate the inputs
        let interestsArray = (interestsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Ensure required fields are filled
        if fullName.isEmpty { showAlert(title: "Missing", message: "Please enter your name."); return }
        if contact.isEmpty { showAlert(title: "Missing", message: "Please enter your contact."); return }
        if interestsArray.isEmpty { showAlert(title: "Missing", message: "Please enter at least one interest (separate by commas)."); return }

        isSaving = true
        setSavingUI(true)

        // If a new image is selected, upload it
        if let imgData = selectedImageData {
            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let urlString):
                    self.selectedImageURL = urlString
                    self.saveToFirestore(uid: uid, fullName: fullName, contact: contact, interests: interestsArray, imageURL: urlString)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.setSavingUI(false)
                        self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    }
                }
            }
        } else {
            // No new image, save without the image URL
            saveToFirestore(uid: uid, fullName: fullName, contact: contact, interests: interestsArray, imageURL: selectedImageURL)
        }
    }

    // MARK: - Firestore save
    private func saveToFirestore(uid: String, fullName: String, contact: String, interests: [String], imageURL: String?) {
        var data: [String: Any] = [
            "fullName": fullName,
            "contact": contact,
            "interests": interests,
            "profileCompleted": true
        ]

        if let imageURL = imageURL, !imageURL.isEmpty {
            data["imageURL"] = imageURL
        }

        // Save profile data to Firestore
        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isSaving = false
                self.setSavingUI(false)

                if let err = err {
                    self.showAlert(title: "Error", message: "Failed to save profile: \(err.localizedDescription)")
                    return
                }

                // If save is successful, update the local profile data
                let updated = SeekerProfile(name: fullName, interests: interests, contact: contact, imageURL: imageURL)
                self.onSave?(updated)  // Call the onSave closure
                self.navigationController?.popViewController(animated: true)  // Go back to the previous screen
            }
        }
    }

    // MARK: - Image loader
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.profileImageView.image = img }
        }.resume()
    }

    // MARK: - Cloudinary upload (Unsigned)
    private func uploadToCloudinary(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func append(_ string: String) { body.append(string.data(using: .utf8)!) }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        append("\(uploadPreset)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        append("\r\n")
        append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { DispatchQueue.main.async { completion(.failure(error)) }; return }
            guard let data = data else { DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: -1))) }; return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let secureURL = json?["secure_url"] as? String {
                    DispatchQueue.main.async { completion(.success(secureURL)) }
                } else {
                    let message = (json?["error"] as? [String: Any])?["message"] as? String ?? "Unknown Cloudinary error"
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Cloudinary", code: -2,
                                                   userInfo: [NSLocalizedDescriptionKey: message])))
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - UI helpers
    private func setSavingUI(_ saving: Bool) {
        view.isUserInteractionEnabled = !saving
        if saving {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saving...", style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
