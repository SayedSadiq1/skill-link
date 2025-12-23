import UIKit



class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var briefTextView: UITextView!
    @IBOutlet weak var contactTextField: UITextField!
    
    @IBOutlet weak var briefContainerView: UIView!
    
    @IBOutlet weak var skillsContainerView: UIView!

    // Receive current data
    var profile: UserProfile!

    // Send updated data back
    var onSave: ((UserProfile) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fill fields with existing values
        nameTextField.text = profile.name
        skillsTextField.text = profile.skills.joined(separator: ", ")
        briefTextView.text = profile.brief
        contactTextField.text = profile.contact

        // Style brief text view (to look like your design)
        briefTextView.layer.cornerRadius = 8
        briefTextView.layer.borderWidth = 1
        briefTextView.layer.borderColor = UIColor.systemGray4.cgColor
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        
        
        // Brief (UITextView display-only)
        briefTextView.isEditable = false
        briefTextView.isSelectable = false
        briefTextView.isScrollEnabled = true

        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.textColor = .label
        briefTextView.backgroundColor = UIColor.systemGray6

        briefTextView.layer.cornerRadius = 8
        briefTextView.layer.borderWidth = 1
        briefTextView.layer.borderColor = UIColor.systemGray4.cgColor
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        briefTextView.text = """
        Experienced in trading, crypto, and mining services.
        I provide clear guidance, fast communication,
        and dependable results.
        """

    
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
            contact: contactTextField.text ?? ""
        )

        onSave?(updated)
        navigationController?.popViewController(animated: true)
    }
}
