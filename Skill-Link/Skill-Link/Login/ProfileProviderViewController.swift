import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    private let db = Firestore.firestore()

    private var currentProfile: UserProfile?

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Skills container style
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Make skills chips look centered when there is 1 (and nice spacing for more)
        setupSkillsStackView()

        // Contact container style
        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        contactLabel.font = .systemFont(ofSize: 16)
        contactLabel.textColor = .label

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

        // Brief view is display only
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

        loadProfileFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make the profile image a circle
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    private func setupSkillsStackView() {
        // These settings helps centering chips when there is only 1
        skillsStackView.axis = .horizontal
        skillsStackView.alignment = .center
        skillsStackView.distribution = .equalSpacing
        skillsStackView.spacing = 8

        // Add some padding so chips dont touch the border
        skillsStackView.isLayoutMarginsRelativeArrangement = true
        skillsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }

    // MARK: - Firestore load
    private func loadProfileFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showSimpleAlert(title: "Error", message: "No logged-in user. Please login again.")
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            DispatchQueue.main.async {
                if let err = err {
                    self.showSimpleAlert(title: "Error", message: "Failed to load profile: \(err.localizedDescription)")
                    return
                }

                let data = snap?.data() ?? [:]

                let name = (data["fullName"] as? String ?? "")
                let contact = (data["contact"] as? String ?? "")
                let brief = (data["brief"] as? String ?? "")
                let imageURL = (data["imageURL"] as? String)
                let skills = data["skills"] as? [String] ?? []

                self.currentProfile = UserProfile(
                    name: name,
                    skills: skills,
                    brief: brief,
                    contact: contact,
                    imageURL: imageURL
                )

                self.applyProfileToUI()
                self.saveUserProfileLocally()
            }
        }
    }

    // MARK: - Apply to UI
    private func applyProfileToUI() {
        guard let currentProfile else { return }

        nameLabel.text = currentProfile.name.isEmpty ? "No Name" : currentProfile.name
        contactLabel.text = currentProfile.contact.isEmpty ? "-" : currentProfile.contact
        briefTextView.text = currentProfile.brief.isEmpty ? "-" : currentProfile.brief

        showSkills(currentProfile.skills)

        if let urlString = currentProfile.imageURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.profileImageView.image = img }
        }.resume()
    }

    // MARK: - Local save
    private func saveUserProfileLocally() {
        guard let currentProfile else { return }

        let userProfile = UserProfile(
            name: currentProfile.name,
            skills: currentProfile.skills,
            brief: currentProfile.brief,
            contact: currentProfile.contact,
            imageURL: currentProfile.imageURL,
            id: Auth.auth().currentUser?.uid
        )

        if let encodedProfile = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }

    // MARK: - Continue
    @IBAction func continueTapped(_ sender: UIButton) {
        guard currentProfile != nil else {
            showSimpleAlert(title: "Wait", message: "Profile not loaded yet.")
            return
        }

        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        if let providerHomeVC = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController") as? ProviderHomeViewController {
            navigationController?.pushViewController(providerHomeVC, animated: true)
        }
    }

    // MARK: - Edit
    @IBAction func editTapped(_ sender: UIButton) {
        guard let currentProfile else {
            showSimpleAlert(title: "Wait", message: "Profile not loaded yet.")
            return
        }

        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController

        vc.profile = currentProfile

        vc.onSave = { [weak self] updated in
            guard let self else { return }
            self.currentProfile = updated
            self.applyProfileToUI()
            self.showSuccessBanner()
            self.saveUserProfileLocally()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Skills chips
    private func showSkills(_ skills: [String]) {
        skillsStackView.arrangedSubviews.forEach {
            skillsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if skills.isEmpty {
            let chip = makeChip(text: "No skills")
            skillsStackView.addArrangedSubview(chip)
            return
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
            let insets = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
            super.drawText(in: rect.inset(by: insets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + horizontalPadding * 2, height: size.height + verticalPadding * 2)
        }
    }

    // MARK: - Alerts
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Success banner
    private func showSuccessBanner() {
        successBanner?.removeFromSuperview()

        let banner = UIView()
        banner.backgroundColor = UIColor.systemGreen
        banner.layer.cornerRadius = 12
        banner.alpha = 0

        let label = UILabel()
        label.text = "Profile Updated Successfully"
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

        UIView.animate(withDuration: 0.2) { banner.alpha = 1 }

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
