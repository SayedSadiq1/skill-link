import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles editing seeker profile
final class EditProfileSeekerViewController: BaseViewController {

    // Profile input fields and image
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    // Passed profile and save callback
    var profile: SeekerProfile?
    var onSave: ((SeekerProfile) -> Void)?

    // Firebase and helpers
    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?

    // Cloudinary config
    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned"

    // Image and state flags
    private var selectedImageData: Data?
    private var selectedImageURL: String?
    private var isSaving = false

    // Loading indicator
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Apply circle avatar style
        profileImageView.applyCircleAvatarNoCrop()

        // Style text fields
        styleTextField(nameTextField)
        styleTextField(interestsTextField)
        styleTextField(contactTextField)

        // Enable image tap to change photo
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        )

        // Setup loading spinner
        setupSpinner()

        guard let profile else { return }

        // Fill fields with current profile data
        nameTextField.text = profile.name
        interestsTextField.text = profile.interests.joined(separator: ", ")
        contactTextField.text = profile.contact
        selectedImageURL = profile.imageURL

        if let urlString = profile.imageURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep profile image circular
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.updateCircleMask()
    }

    // Setup spinner in center
    private func setupSpinner() {
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true
        view.addSubview(loadingSpinner)

        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Toggle loading state
    private func setLoading(_ loading: Bool) {
        loading ? loadingSpinner.startAnimating() : loadingSpinner.stopAnimating()
        view.isUserInteractionEnabled = !loading
    }

    // Apply common style to text fields
    private func styleTextField(_ tf: UITextField) {
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .white
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftViewMode = .always
    }

    // Open photo picker to change image
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
            self.profileImageView.applyCircleAvatarNoCrop()
            self.profileImageView.updateCircleMask()
        }
        photoPicker?.presentPicker()
    }

    // Save updated profile
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let interests = (interestsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !name.isEmpty, !contact.isEmpty, !interests.isEmpty else { return }

        isSaving = true
        setLoading(true)

        // Upload image if changed
        if let imgData = selectedImageData {
            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let url):
                    self.saveToFirestore(
                        uid: uid,
                        name: name,
                        contact: contact,
                        interests: interests,
                        imageURL: url
                    )
                case .failure:
                    self.isSaving = false
                    self.setLoading(false)
                }
            }
        } else {
            saveToFirestore(
                uid: uid,
                name: name,
                contact: contact,
                interests: interests,
                imageURL: selectedImageURL
            )
        }
    }

    // Save updated profile to firestore
    private func saveToFirestore(
        uid: String,
        name: String,
        contact: String,
        interests: [String],
        imageURL: String?
    ) {
        var data: [String: Any] = [
            "fullName": name,
            "contact": contact,
            "interests": interests,
            "role": "seeker",
            "profileCompleted": true
        ]

        if let imageURL { data["imageURL"] = imageURL }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] _ in
            guard let self else { return }

            // Save profile locally
            let localProfile = UserProfile(
                id: uid,
                fullName: name,
                contact: contact,
                imageURL: imageURL,
                role: .seeker,
                skills: interests,
                brief: "",
                isSuspended: false
            )
            LocalUserStore.saveProfile(localProfile)

            self.setLoading(false)
            self.onSave?(
                SeekerProfile(
                    name: name,
                    interests: interests,
                    contact: contact,
                    imageURL: imageURL,
                    id: uid
                )
            )

            self.navigationController?.popViewController(animated: true)
        }
    }

    // Load image from url
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            if let data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImageView.image = img
                    self.profileImageView.applyCircleAvatarNoCrop()
                    self.profileImageView.updateCircleMask()
                }
            }
        }.resume()
    }

    // Upload image to cloudinary
    private func uploadToCloudinary(
        imageData: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func add(_ s: String) { body.append(s.data(using: .utf8)!) }

        add("--\(boundary)\r\n")
        add("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        add("\(uploadPreset)\r\n")
        add("--\(boundary)\r\n")
        add("Content-Disposition: form-data; name=\"file\"; filename=\"img.jpg\"\r\n")
        add("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        add("\r\n--\(boundary)--\r\n")

        req.httpBody = body

        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }

            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let url = json["secure_url"] as? String {
                completion(.success(url))
            } else {
                completion(.failure(NSError(domain: "Cloudinary", code: -1)))
            }
        }.resume()
    }
}
