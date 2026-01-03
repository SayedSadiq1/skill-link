import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles provider profile setup flow
final class SetupProfileProviderViewController: BaseViewController, UITextViewDelegate {

    // UI elements for provider profile
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!

    // Firebase and helpers
    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?
    private var selectedImage: UIImage?

    // State flags and cached values
    private var isSaving = false
    private var loadedFullName: String = ""

    // Loading indicator shown while saving
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    // Disable back button on this screen
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Block back swipe
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Set default profile image
        if profileImageView.image == nil {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        profileImageView.applyCircleAvatarNoCrop()

        // Enable tapping image to change photo
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        )
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Style brief input area
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        // Setup brief text view
        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        briefTextView.delegate = self
        setBriefPlaceholderIfNeeded()

        // Add loading spinner
        setupLoadingSpinner()

        // Load user name from firestore
        loadFullNameFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make profile image fully round
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.updateCircleMask()
    }

    // Spinner setup in center of screen
    private func setupLoadingSpinner() {
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true
        view.addSubview(loadingSpinner)

        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Toggle loading state
    private func setLoading(_ isLoading: Bool) {
        isLoading ? loadingSpinner.startAnimating() : loadingSpinner.stopAnimating()
    }

    // Load full name from firestore
    private func loadFullNameFromFirestore() {
        guard let uid = LocalUserStore.currentUserId() ?? Auth.auth().currentUser?.uid else {
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

                // Save basic profile locally
                self.saveUserProfileLocally(
                    uid: uid,
                    name: name,
                    skills: [],
                    brief: "",
                    contact: self.contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                    imageURL: nil
                )
            }
        }
    }

    // Setup placeholder text for brief
    private func setBriefPlaceholderIfNeeded() {
        if briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            briefTextView.text = "Brief..."
            briefTextView.textColor = .systemGray3
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray3 {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setBriefPlaceholderIfNeeded()
        }
    }

    // Runs when continue button is tapped
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard validateRequiredFields() else { return }

        guard let uid = LocalUserStore.currentUserId() ?? Auth.auth().currentUser?.uid else {
            showAlert(message: "No logged-in user found.")
            return
        }

        isSaving = true
        sender.isEnabled = false
        setLoading(true)

        // Upload image first if selected
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
            saveProviderProfile(uid: uid, imageURL: nil, sender: sender)
        }
    }

    // Save provider data to firestore
    private func saveProviderProfile(uid: String, imageURL: String?, sender: UIButton) {
        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let briefFinal =
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

                // Update local profile after save
                self.saveUserProfileLocally(
                    uid: uid,
                    name: self.loadedFullName,
                    skills: skillsArray,
                    brief: briefFinal,
                    contact: contact,
                    imageURL: imageURL
                )

                self.finishSaving(sender: sender) {
                    self.goToProfileProvider()
                }
            }
        }
    }

    // Save provider profile locally
    private func saveUserProfileLocally(
        uid: String,
        name: String,
        skills: [String],
        brief: String,
        contact: String,
        imageURL: String?
    ) {
        let profile = UserProfile(
            id: uid,
            fullName: name,
            contact: contact,
            imageURL: imageURL,
            role: .provider,
            skills: skills,
            brief: brief,
            isSuspended: false
        )

        LocalUserStore.saveProfile(profile)
    }

    // Finish saving and unlock UI
    private func finishSaving(sender: UIButton, completion: (() -> Void)? = nil) {
        setLoading(false)
        isSaving = false
        sender.isEnabled = true
        completion?()
    }

    // Navigate to provider profile screen
    private func goToProfileProvider() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(
            withIdentifier: "ProfileProviderViewController"
        ) as? ProfileProviderViewController else {
            fatalError("Could not find ProfileProviderViewController in storyboard.")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // Validate required input fields
    private func validateRequiredFields() -> Bool {
        if loadedFullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(message: "Your name is missing in firebase. Please register again.")
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

    // Shows alert popup
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Setup Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Opens photo picker for profile image
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImage = image
        }
        photoPicker?.presentPicker()
    }
}
