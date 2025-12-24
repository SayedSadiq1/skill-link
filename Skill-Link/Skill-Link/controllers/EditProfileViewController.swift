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
    private var selectedImageData: Data?   // ✅ stores current/updated image

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ Make image clickable
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        // ✅ Style containers
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        briefContainerView.layer.cornerRadius = 10
        briefContainerView.layer.borderWidth = 1
        briefContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // ✅ Brief styling (editable)
        briefTextView.isEditable = true
        briefTextView.isSelectable = true
        briefTextView.isScrollEnabled = true
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.backgroundColor = .clear
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // ✅ Fill fields
        guard let profile = profile else {
            print("❌ EditProfileViewController: profile is nil (not passed)")
            return
        }

        nameTextField.text = profile.name
        skillsTextField.text = profile.skills.joined(separator: ", ")
        briefTextView.text = profile.brief
        contactTextField.text = profile.contact

        // ✅ Show existing image from setup (if exists)
        selectedImageData = profile.imageData
        if let data = profile.imageData, let img = UIImage(data: data) {
            profileImageView.image = img
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill") // optional fallback
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ Make image circular reliably (after layout)
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
        let skillsArray = (skillsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let updated = UserProfile(
            name: nameTextField.text ?? "",
            skills: skillsArray,
            brief: briefTextView.text ?? "",
            contact: contactTextField.text ?? "",
            imageData: selectedImageData          // ✅ THIS updates the profile image
        )

        onSave?(updated)
        navigationController?.popViewController(animated: true)
    }
}
