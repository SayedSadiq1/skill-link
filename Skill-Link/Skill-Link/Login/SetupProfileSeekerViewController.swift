import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles seeker profile setup flow
final class SetupProfileSeekerViewController: BaseViewController {

    // UI elements for seeker profile
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!

    // Firebase and helpers
    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?
    private var selectedImage: UIImage?

    // State flags and cached values
    private var isSaving = false
    private var loadedFullName: String = ""

    // Loading indicator only
    private let loadingSpinner = UIActivityIndicatorView(style: .large)

    // Disable back button here
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Block back swipe navigation
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Setup default profile image and tap action
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        )
        profileImageView.applyCircleAvatarNoCrop()

        // Setup loader and load user name
        setupSpinner()
        loadFullName()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep image circular after layout
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.updateCircleMask()
    }

    // Spinner setup in center
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

    // Load user full name from firestore
    private func loadFullName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("User").document(uid).getDocument { [weak self] snap, _ in
            guard let self else { return }

            let name = snap?.data()?["fullName"] as? String ?? ""
            self.loadedFullName = name

            DispatchQueue.main.async {
                self.fullNameLabel.text = name.isEmpty ? "Name not set" : name
            }
        }
    }

    // Runs when continue button is tapped
    @IBAction func continueTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard validate() else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isSaving = true
        sender.isEnabled = false
        setLoading(true)

        // Upload image first if user picked one
        if let image = selectedImage {
            CloudinaryUploader.shared.uploadImage(image) { [weak self] result in
                guard let self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self.saveProfile(uid: uid, imageURL: url, sender: sender)
                    case .failure(let error):
                        self.finish(sender)
                        self.showAlert(error.localizedDescription)
                    }
                }
            }
        } else {
            saveProfile(uid: uid, imageURL: nil, sender: sender)
        }
    }

    // Save seeker profile to firestore
    private func saveProfile(uid: String, imageURL: String?, sender: UIButton) {
        let interests = interestsTextField.text?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        let contact = contactTextField.text ?? ""

        var data: [String: Any] = [
            "fullName": loadedFullName,
            "interests": interests,
            "contact": contact,
            "role": "seeker",
            "profileCompleted": true
        ]

        if let imageURL { data["imageURL"] = imageURL }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }

            DispatchQueue.main.async {
                if let err {
                    self.finish(sender)
                    self.showAlert(err.localizedDescription)
                    return
                }

                // Save profile locally
                let profile = UserProfile(
                    id: uid,
                    fullName: self.loadedFullName,
                    contact: contact,
                    imageURL: imageURL,
                    role: .seeker,
                    skills: interests,
                    brief: "",
                    isSuspended: false
                )
                LocalUserStore.saveProfile(profile)

                self.finish(sender) {
                    self.goNext()
                }
            }
        }
    }

    // Finish saving and unlock UI
    private func finish(_ sender: UIButton, completion: (() -> Void)? = nil) {
        setLoading(false)
        isSaving = false
        sender.isEnabled = true
        completion?()
    }

    // Navigate to seeker profile screen
    private func goNext() {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProfileSeekerViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // Validate required input fields
    private func validate() -> Bool {
        let interests = interestsTextField.text?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        if interests.isEmpty {
            showAlert("Enter at least 1 interest")
            return false
        }

        if interests.count > 3 {
            showAlert("Max 3 interests")
            return false
        }

        if contactTextField.text?.isEmpty == true {
            showAlert("Enter contact")
            return false
        }

        return true
    }

    // Shows alert popup
    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: "Setup Profile", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    // Opens photo picker for profile image
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] img in
            guard let self else { return }
            self.profileImageView.image = img
            self.selectedImage = img
            self.profileImageView.applyCircleAvatarNoCrop()
        }
        photoPicker?.presentPicker()
    }
}
