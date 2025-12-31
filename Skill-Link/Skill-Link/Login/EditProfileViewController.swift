import UIKit
import FirebaseAuth
import FirebaseFirestore

final class EditProfileViewController: BaseViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var briefTextView: UITextView!
    @IBOutlet weak var contactTextField: UITextField!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var skillsContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!

    var profile: UserProfile?
    var onSave: ((UserProfile) -> Void)?

    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?

    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned"

    private var selectedImageData: Data?
    private var selectedImageURL: String?

    private var isSaving = false

    // Loading circle (no "Saving..." label)
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tap on image to change it
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        // Container style for the skills box
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Container style for the brief box
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Brief text view style
        briefTextView.isEditable = true
        briefTextView.isSelectable = true
        briefTextView.isScrollEnabled = true
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.backgroundColor = .clear
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // Setup loading spinner (just a circle)
        setupLoadingSpinner()

        guard let profile = profile else {
            print("EditProfileViewController: profile is nil")
            return
        }

        // Fill inputs with existing values
        nameTextField.text = profile.name
        skillsTextField.text = profile.skills.joined(separator: ", ")
        briefTextView.text = profile.brief
        contactTextField.text = profile.contact

        // Keep old image url unless user uploads new one
        selectedImageURL = profile.imageURL

        if let urlString = profile.imageURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make profile image round
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Spinner setup
    private func setupLoadingSpinner() {
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true

        view.addSubview(loadingSpinner)

        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
    }

    // MARK: - Image picker
    @objc private func changePhotoTapped() {
        // Open photo picker so user can choose new picture
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()
    }

    // MARK: - Save
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "No logged in user. Please login again.")
            return
        }

        let fullName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let brief = briefTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Basic validation so we dont save empty stuff
        if fullName.isEmpty { showAlert(title: "Missing", message: "Please enter your name."); return }
        if contact.isEmpty { showAlert(title: "Missing", message: "Please enter your contact."); return }
        if skillsArray.isEmpty { showAlert(title: "Missing", message: "Please enter at least one skill."); return }

        isSaving = true
        setSavingUI(true)

        // If user selected a new image, upload it first
        if let imgData = selectedImageData {
            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let urlString):
                    self.selectedImageURL = urlString
                    self.saveToFirestore(
                        uid: uid,
                        fullName: fullName,
                        contact: contact,
                        brief: brief,
                        skills: skillsArray,
                        imageURL: urlString
                    )

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.setSavingUI(false)
                        self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    }
                }
            }
        } else {
            // No new image, save direct with old url
            saveToFirestore(
                uid: uid,
                fullName: fullName,
                contact: contact,
                brief: brief,
                skills: skillsArray,
                imageURL: selectedImageURL
            )
        }
    }

    // MARK: - Firestore save
    private func saveToFirestore(uid: String,
                                 fullName: String,
                                 contact: String,
                                 brief: String,
                                 skills: [String],
                                 imageURL: String?) {

        var data: [String: Any] = [
            "fullName": fullName,
            "contact": contact,
            "brief": brief,
            "skills": skills,
            "profileCompleted": true
        ]

        if let imageURL = imageURL, !imageURL.isEmpty {
            data["imageURL"] = imageURL
        }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isSaving = false
                self.setSavingUI(false)

                if let err = err {
                    self.showAlert(title: "Error", message: "Failed to save profile: \(err.localizedDescription)")
                    return
                }

                // Build updated object for callback
                var updated = UserProfile(
                    name: fullName,
                    skills: skills,
                    brief: brief,
                    contact: contact,
                    imageURL: imageURL
                )
                updated.id = uid

                // Save updated profile localy too
                self.saveUserProfileLocally(updated)

                self.onSave?(updated)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Local save
    private func saveUserProfileLocally(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    // MARK: - Image loader
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
        }.resume()
    }

    // MARK: - Cloudinary upload
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
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: -1))) }
                return
            }

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
        // Block touches while saving and show spinner
        view.isUserInteractionEnabled = !saving
        setLoading(saving)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
