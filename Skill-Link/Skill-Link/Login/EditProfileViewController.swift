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

    // loading circle only
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        profileImageView.applyCircleAvatarNoCrop()
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        )

        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        setupSpinner()

        guard let profile else { return }

        nameTextField.text = profile.name
        skillsTextField.text = profile.skills.joined(separator: ", ")
        briefTextView.text = profile.brief
        contactTextField.text = profile.contact
        selectedImageURL = profile.imageURL

        if let url = profile.imageURL.flatMap(URL.init) {
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
        profileImageView.updateCircleMask()
    }

    // MARK: - Spinner
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setLoading(_ loading: Bool) {
        view.isUserInteractionEnabled = !loading
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    // MARK: - Image picker
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] img in
            guard let self else { return }
            self.profileImageView.image = img
            self.selectedImageData = img.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()
    }

    // MARK: - Save
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaving,
              let uid = Auth.auth().currentUser?.uid,
              let profile else { return }

        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let brief = briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let skills = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if name.isEmpty || contact.isEmpty || skills.isEmpty { return }

        isSaving = true
        setLoading(true)

        if let imgData = selectedImageData {
            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let url):
                    self.save(uid, name, contact, brief, skills, url)
                case .failure:
                    self.finishSave()
                }
            }
        } else {
            save(uid, name, contact, brief, skills, selectedImageURL)
        }
    }

    private func save(_ uid: String,
                      _ name: String,
                      _ contact: String,
                      _ brief: String,
                      _ skills: [String],
                      _ imageURL: String?) {

        var data: [String: Any] = [
            "fullName": name,
            "contact": contact,
            "brief": brief,
            "skills": skills,
            "profileCompleted": true
        ]

        if let imageURL { data["imageURL"] = imageURL }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] _ in
            guard let self, let old = self.profile else { return }

            let updated = UserProfile(
                id: uid,
                name: name,
                contact: contact,
                imageURL: imageURL,
                role: old.role,
                skills: skills,
                brief: brief,
                isSuspended: old.isSuspended
            )

            LocalUserStore.saveProfile(updated)
            self.onSave?(updated)
            self.finishSave()
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func finishSave() {
        isSaving = false
        setLoading(false)
    }

    // MARK: - Image load
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = img
            }
        }.resume()
    }

    // MARK: - Cloudinary
    private func uploadToCloudinary(imageData: Data,
                                    completion: @escaping (Result<String, Error>) -> Void) {

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

        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err { completion(.failure(err)); return }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let url = json["secure_url"] as? String else { return }
            completion(.success(url))
        }.resume()
    }
}
