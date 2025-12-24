import UIKit

class SetupProfileProviderViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!
    
    @IBOutlet weak var profileImageView: UIImageView!

    private var photoPicker: PhotoPickerHelper?
    private var selectedImageData: Data?   // store chosen photo

    override func viewDidLoad() {
        super.viewDidLoad()

        
        profileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        profileImageView.addGestureRecognizer(tap)

        
        //making image rounded
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
        
        // ✅ Make the container look like a big text field
        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        briefContainerView.backgroundColor = .white
        briefContainerView.clipsToBounds = true

        // ✅ Make the text view look clean inside it
        briefTextView.backgroundColor = .clear
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // ✅ Placeholder behavior (optional but nice)
        briefTextView.delegate = self
        setBriefPlaceholderIfNeeded()
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
    
    @IBAction func continueTapped(_ sender: UIButton) {
        if validateRequiredFields() {
            // ✅ All good → go to next screen
            goToProfileScreen()
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
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func goToProfileScreen() {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        let name = fullNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let contact = contactTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        let skillsArray = skillsTextField.text!
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let briefFinal = (briefTextView.textColor == .systemGray3) ? "" : (briefTextView.text ?? "")

        // ✅ PASS IMAGE DATA HERE
        vc.currentProfile = UserProfile(
            name: name,
            skills: skillsArray,
            brief: briefFinal,
            contact: contact,
            imageData: selectedImageData
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image

            // compress for storage (good enough for now)
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()
    }


    
}
