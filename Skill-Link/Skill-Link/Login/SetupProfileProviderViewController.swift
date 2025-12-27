import UIKit

final class SetupProfileProviderViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!

    @IBOutlet weak var profileImageView: UIImageView!

    private var photoPicker: PhotoPickerHelper?
    private var selectedImage: UIImage?      // preview only
    private var isSaving = false             // avoid double tap

    override func viewDidLoad() {
        super.viewDidLoad()

        // Image tap
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Container like big text field
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        // TextView styling
        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // Placeholder behavior
        briefTextView.delegate = self
        setBriefPlaceholderIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    // MARK: - Placeholder
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

        isSaving = true
        sender.isEnabled = false

        // If user picked a photo → upload first
        if let image = selectedImage {
            showSavingHUD(true)

            CloudinaryUploader.shared.uploadImage(image) { [weak self] result in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.showSavingHUD(false)
                    sender.isEnabled = true
                    self.isSaving = false

                    switch result {
                    case .success(let url):
                        self.goToProfileScreen(imageURL: url)
                    case .failure(let error):
                        self.showAlert(message: "Failed to upload image:\n\(error.localizedDescription)")
                    }
                }
            }
        } else {
            sender.isEnabled = true
            isSaving = false
            goToProfileScreen(imageURL: nil)
        }
    }

    private func validateRequiredFields() -> Bool {
        let fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let skills = skillsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if fullName.isEmpty {
            showAlert(message: "Please enter your full name.")
            return false
        }
        if skills.isEmpty {
            showAlert(message: "Please enter at least one skill.")
            return false
        }
        if contact.isEmpty {
            showAlert(message: "Please enter your contact information.")
            return false
        }
        return true
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
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

    private func goToProfileScreen(imageURL: String?) {
        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController") as? ProfileProviderViewController else {
            fatalError("❌ Could not find ProfileProviderViewController in storyboard. Check Storyboard ID + Custom Class.")
        }

        let name = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let briefFinal: String =
            (briefTextView.textColor == .systemGray3)
            ? ""
            : briefTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let profile = UserProfile(
            name: name,
            skills: skillsArray,
            brief: briefFinal,
            contact: contact,
            imageURL: imageURL
//            role: .provider
        )

        vc.currentProfile = profile
        navigationController?.pushViewController(vc, animated: true)
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
