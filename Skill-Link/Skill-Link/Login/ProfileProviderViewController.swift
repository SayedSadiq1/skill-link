import UIKit

final class ProfileProviderViewController: BaseViewController {

    @IBOutlet weak var skillsStackView: UIStackView!
    @IBOutlet weak var skillsContainerView: UIView!

    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var contactLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!

    @IBOutlet weak var profileImageView: UIImageView!

    private var successBanner: UIView?

    // ✅ TEMP profile (later Firestore)
    var currentProfile = UserProfile(
        name: "Ammar Yaser Ahmed Rabeea",
        skills: ["Trading", "Crypto", "Plumbing"],
        brief: """
        Experienced in trading, crypto, and mining services.
        I provide clear guidance, fast communication,
        and dependable results.
        """,
        contact: "ammar.yaser@example.com",
        imageURL: nil,
        role: .provider
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ ProfileProviderViewController loaded")

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

        applyProfileToUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // ✅ Apply model → UI
    private func applyProfileToUI() {
        nameLabel.text = currentProfile.name
        contactLabel.text = currentProfile.contact
        briefTextView.text = currentProfile.brief
        showSkills(currentProfile.skills)

        // ✅ Load Cloudinary image if exists
        if let urlString = currentProfile.imageURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    // ✅ Simple URL image loader (no libs)
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
        }.resume()
    }

    // ✅ Connect Edit button to this IBAction
    @IBAction func editTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController

        // ✅ PASS DATA
        vc.profile = currentProfile

        // ✅ RECEIVE UPDATED DATA
        vc.onSave = { [weak self] updated in
            guard let self = self else { return }
            self.currentProfile = updated
            self.applyProfileToUI()
            self.showSuccessBanner()
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
            let insets = UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )
            super.drawText(in: rect.inset(by: insets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(
                width: size.width + horizontalPadding * 2,
                height: size.height + verticalPadding * 2
            )
        }
    }

    // ✅ Banner (1 second)
    private func showSuccessBanner() {
        successBanner?.removeFromSuperview()

        let banner = UIView()
        banner.backgroundColor = UIColor.systemGreen
        banner.layer.cornerRadius = 12
        banner.alpha = 0

        let label = UILabel()
        label.text = "✅ Profile Updated Successfully"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.addSubview(label)
        view.addSubview(banner)
        successBanner = banner

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.heightAnchor.constraint(equalToConstant: 40),
            banner.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),

            label.centerXAnchor.constraint(equalTo: banner.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: banner.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: banner.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: banner.trailingAnchor, constant: -12)
        ])

        UIView.animate(withDuration: 0.2) {
            banner.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            UIView.animate(withDuration: 0.2, animations: {
                banner.alpha = 0
            }, completion: { _ in
                banner.removeFromSuperview()
                self?.successBanner = nil
            })
        }
    }
}
