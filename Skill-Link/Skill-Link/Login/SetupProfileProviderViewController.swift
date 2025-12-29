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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // ✅ default image if user doesn't pick one
        if profileImageView.image == nil {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }

        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        briefTextView.delegate = self
        setBriefPlaceholderIfNeeded()

        loadFullNameFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    private func loadFullNameFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            fullNameLabel.text = "No user"
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }
            DispatchQueue.main.async {
                if let err = err {
                    self.fullNameLabel.text = "Error loading name"
                    print("❌ load name error: \(err.localizedDescription)")
                    return
                }

                let data = snap?.data() ?? [:]
                let name = (data["fullName"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                self.loadedFullName = name
                self.fullNameLabel.text = name.isEmpty ? "Name not set" : name
            }
        }
    }

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
        showSavingHUD(true)

        // upload photo if user selected one
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
            // ✅ no photo selected -> save with no imageURL
            self.saveProviderProfile(uid: uid, imageURL: nil, sender: sender)
        }
    }

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

                // ✅ IMPORTANT: dismiss HUD first, THEN navigate
                self.finishSaving(sender: sender) {
                    self.goToProfileProvider()
                }
            }
        }
    }

    private func goToProfileProvider() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController") as? ProfileProviderViewController else {
            fatalError("❌ Could not find ProfileProviderViewController in storyboard. Check Storyboard ID + Custom Class.")
        }

        navigationController?.pushViewController(vc, animated: true)
    }

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

    // ✅ UPDATED: dismiss alert with completion
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
