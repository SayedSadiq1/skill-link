import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SetupProfileSeekerViewController: BaseViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?
    private var selectedImage: UIImage?
    private var isSaving = false

    private var loadedFullName: String = ""

    // Spinner shown while saving (no popup)
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable going back from setup
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Default profile image if user didnt pick one yet
        if profileImageView.image == nil {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        // Setup image tap
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Setup loading spinner (only a circle, no text)
        setupLoadingSpinner()

        // Load name from firestore
        loadFullNameFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make profile image round
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

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

    // MARK: - Load name
    private func loadFullNameFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            fullNameLabel.text = "No user"
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            DispatchQueue.main.async {
                if err != nil {
                    self.fullNameLabel.text = "Error loading name"
                    return
                }

                let data = snap?.data() ?? [:]
                let name = (data["fullName"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                self.loadedFullName = name
                self.fullNameLabel.text = name.isEmpty ? "Name not set" : name

                // Save the name localy too (even before continue)
                self.saveUserProfileLocally(
                    name: self.loadedFullName,
                    interests: [],
                    contact: self.contactTextField.text ?? "",
                    imageURL: nil
                )
            }
        }
    }

    // MARK: - Continue
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard validateRequiredFields() else { return }

        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(message: "No logged-in user found.")
            return
        }

        isSaving = true
        sender.isEnabled = false
        setLoading(true)

        // Upload image if exists, otherwise save direct
        if let image = selectedImage {
            CloudinaryUploader.shared.uploadImage(image) { [weak self] result in
                guard let self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self.saveSeekerProfile(uid: uid, imageURL: url, sender: sender)
                    case .failure(let error):
                        self.finishSaving(sender: sender)
                        self.showAlert(message: "Failed to upload image:\n\(error.localizedDescription)")
                    }
                }
            }
        } else {
            saveSeekerProfile(uid: uid, imageURL: nil, sender: sender)
        }
    }

    // MARK: - Save seeker profile
    private func saveSeekerProfile(uid: String, imageURL: String?, sender: UIButton) {
        let interestsArray = (interestsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        var data: [String: Any] = [
            "fullName": loadedFullName,
            "interests": interestsArray,
            "contact": contact,
            "role": "seeker",
            "profileCompleted": true
        ]

        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }

            DispatchQueue.main.async {
                if let err = err {
                    self.finishSaving(sender: sender)
                    self.showAlert(message: "Failed to save profile:\n\(err.localizedDescription)")
                    return
                }

                // Update local data after save is done
                self.saveUserProfileLocally(
                    name: self.loadedFullName,
                    interests: interestsArray,
                    contact: contact,
                    imageURL: imageURL
                )

                self.finishSaving(sender: sender) {
                    self.goToProfileSeeker()
                }
            }
        }
    }

    private func saveUserProfileLocally(name: String, interests: [String], contact: String, imageURL: String?) {
        // Seeker interests stored in skills to keep one local model
        let profile = UserProfile(
            name: name,
            skills: interests,
            brief: "",
            contact: contact,
            imageURL: imageURL,
            id: Auth.auth().currentUser?.uid
        )

        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    private func finishSaving(sender: UIButton, completion: (() -> Void)? = nil) {
        setLoading(false)
        isSaving = false
        sender.isEnabled = true
        completion?()
    }

    private func goToProfileSeeker() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "ProfileSeekerViewController") as? ProfileSeekerViewController else {
            fatalError("Could not find ProfileSeekerViewController in storyboard.")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Validation
    private func validateRequiredFields() -> Bool {
        if loadedFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(message: "Your name is missing in firebase. Please register again.")
            return false
        }

        let interestsArray = (interestsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if interestsArray.isEmpty {
            showAlert(message: "Please enter at least one interest (separate by commas).")
            return false
        }

        if interestsArray.count > 3 {
            showAlert(message: "You can select a maximum of 3 interests only.")
            return false
        }

        if contact.isEmpty {
            showAlert(message: "Please enter your contact information.")
            return false
        }

        return true
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Setup Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Photo picker
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImage = image
        }
        photoPicker?.presentPicker()
    }
}
