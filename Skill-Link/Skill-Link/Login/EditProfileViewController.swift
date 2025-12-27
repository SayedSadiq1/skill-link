import UIKit

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

    private var photoPicker: PhotoPickerHelper?

    // Cloudinary
    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned" // <-- change if yours is different

    // image state
    private var selectedImageData: Data?        // chosen new image (pending upload)
    private var selectedImageURL: String?       // existing or uploaded url

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ Image tap
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        // ✅ Style containers
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // ✅ Brief styling
        briefTextView.isEditable = true
        briefTextView.isSelectable = true
        briefTextView.isScrollEnabled = true
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.backgroundColor = .clear
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        guard let profile = profile else {
            print("❌ EditProfileViewController: profile is nil (not passed)")
            return
        }

        // ✅ Fill text fields
        nameTextField.text = profile.name
        skillsTextField.text = profile.skills.joined(separator: ", ")
        briefTextView.text = profile.brief
        contactTextField.text = profile.contact

        // ✅ Show existing image URL
        selectedImageURL = profile.imageURL
        if let urlString = profile.imageURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let oldProfile = profile else { return }

        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // If user picked a new image => upload first then save
        if let imgData = selectedImageData {
            setSavingUI(true)

            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }
                self.setSavingUI(false)

                switch result {
                case .success(let urlString):
                    self.selectedImageURL = urlString
                    let updated = UserProfile(
                        name: self.nameTextField.text ?? "",
                        skills: skillsArray,
                        brief: self.briefTextView.text ?? "",
                        contact: self.contactTextField.text ?? "",
                        imageURL: urlString
//                        role: oldProfile.role
                    )
                    self.onSave?(updated)
                    self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                }
            }
        } else {
            // No new image picked => just save existing URL
            let updated = UserProfile(
                name: nameTextField.text ?? "",
                skills: skillsArray,
                brief: briefTextView.text ?? "",
                contact: contactTextField.text ?? "",
                imageURL: selectedImageURL
//                role: oldProfile.role
            )

            onSave?(updated)
            navigationController?.popViewController(animated: true)
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

    // MARK: - Cloudinary upload (Unsigned)
    private func uploadToCloudinary(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }

        // upload_preset
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        append("\(uploadPreset)\r\n")

        // file
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        append("\r\n")

        append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
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

                // Cloudinary returns secure_url
                if let secureURL = json?["secure_url"] as? String {
                    DispatchQueue.main.async { completion(.success(secureURL)) }
                } else {
                    let message = (json?["error"] as? [String: Any])?["message"] as? String ?? "Unknown Cloudinary error"
                    DispatchQueue.main.async { completion(.failure(NSError(domain: "Cloudinary", code: -2, userInfo: [NSLocalizedDescriptionKey: message]))) }
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
