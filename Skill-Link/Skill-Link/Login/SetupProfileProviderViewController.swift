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

    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?
    private var selectedImage: UIImage?
    private var isSaving = false

    private var loadedFullName: String = ""

    // just a loading circle while we save, no popup view
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // dont let user go back from setup screen
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // put a default image if user didnt pick one
        if profileImageView.image == nil {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        // tap the image to change it
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // style the brief area like the design
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        // basic text view setup
        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        briefTextView.delegate = self
        setBriefPlaceholderIfNeeded()

        // add loading spinner in the middle
        setupLoadingSpinner()

        // read the name from firestore
        loadFullNameFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // make profile image round
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
        // try local uid first so it stays consistent in the app
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

                // save name localy so other pages can use it
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

    // MARK: - Placeholder
    private func setBriefPlaceholderIfNeeded() {
        if briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            briefTextView.text = "Brief..."
            briefTextView.textColor = .systemGray3
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // remove placeholder once user starts typing
        if textView.textColor == .systemGray3 {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // add placeholder back if it was left empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setBriefPlaceholderIfNeeded()
        }
    }

    // MARK: - Continue
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

        // upload image if user selected one, otherwise save without it
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

    // MARK: - Save provider profile
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

                // update local profile after we saved firestore
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

    private func saveUserProfileLocally(uid: String, name: String, skills: [String], brief: String, contact: String, imageURL: String?) {
        // save everything in one place so other screens can read it
        let profile = UserProfile(
            id: uid,
            name: name,
            contact: contact,
            imageURL: imageURL,
            role: .provider,
            skills: skills,
            brief: brief,
            isSuspended: false
        )

        LocalUserStore.saveProfile(profile)
    }

    private func finishSaving(sender: UIButton, completion: (() -> Void)? = nil) {
        // turn off loader and unlock the UI again
        setLoading(false)
        isSaving = false
        sender.isEnabled = true
        completion?()
    }

    private func goToProfileProvider() {
        // go to provider profile screen after setup done
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController") as? ProfileProviderViewController else {
            fatalError("Could not find ProfileProviderViewController in storyboard.")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Validation
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

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Setup Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Photo picking
    @objc private func changePhotoTapped() {
        // open photos and let user pick a new profile picture
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImage = image
        }
        photoPicker?.presentPicker()
    }
}
