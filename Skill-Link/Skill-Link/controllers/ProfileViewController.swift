import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var skillsStackView: UIStackView!
    @IBOutlet weak var skillsContainerView: UIView!

    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var contactLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!

    // ✅ Profile data (TEMP now, later Firebase)
    var currentProfile = UserProfile(
        name: "Ammar Yaser Ahmed Rabeea",
        skills: ["Trading", "Crypto", "Plumbing"],
        brief: """
        Experienced in trading, crypto, and mining services.
        I provide clear guidance, fast communication,
        and dependable results.
        """,
        contact: "ammar.yaser@example.com"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ ProfileViewController loaded")

        // Skills container styling
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Contact container styling (display-only)
        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        contactLabel.font = .systemFont(ofSize: 16)
        contactLabel.textColor = .label

        // Name (display-only)
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

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

        // ✅ Fill UI from currentProfile (instead of hardcoded values)
        applyProfileToUI()
    }

    // ✅ Apply model → UI
    private func applyProfileToUI() {
        nameLabel.text = currentProfile.name
        contactLabel.text = currentProfile.contact
        briefTextView.text = currentProfile.brief
        showSkills(currentProfile.skills)
    }

    // ✅ Connect your Edit button to this IBAction in storyboard
    @IBAction func editTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController

        vc.profile = currentProfile

        vc.onSave = { [weak self] updated in
            guard let self = self else { return }
            self.currentProfile = updated
            self.applyProfileToUI()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Skills chips
    private func showSkills(_ skills: [String]) {
        skillsStackView.arrangedSubviews.forEach {
            skillsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for skill in skills {
            let chip = makeChip(text: skill)
            skillsStackView.addArrangedSubview(chip)
        }
    }

    private func makeChip(text: String) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.horizontalPadding = 12
        label.verticalPadding = 6
        return label
    }

    final class PaddingLabel: UILabel {
        var horizontalPadding: CGFloat = 12
        var verticalPadding: CGFloat = 6

        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets(top: verticalPadding, left: horizontalPadding,
                                      bottom: verticalPadding, right: horizontalPadding)
            super.drawText(in: rect.inset(by: insets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + horizontalPadding * 2,
                          height: size.height + verticalPadding * 2)
        }
    }
}
