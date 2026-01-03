import UIKit
import FirebaseAuth
import FirebaseFirestore

// Shows provider profile details
final class ProfileProviderViewController: BaseViewController {

    // Skills related views
    @IBOutlet weak var skillsStackView: UIStackView!
    @IBOutlet weak var skillsContainerView: UIView!

    // Contact related views
    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var contactLabel: UILabel!

    // Name and brief section
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var briefContainerView: UIView!
    @IBOutlet weak var briefTextView: UITextView!

    // Profile image and edit button
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!

    // Firestore and state
    private let db = Firestore.firestore()

    var currentProfile: UserProfile?

    // Disable back button
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style skills section
        skillsContainerView.layer.cornerRadius = 10
        skillsContainerView.layer.borderWidth = 1
        skillsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Style contact section
        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        // Setup fonts
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        contactLabel.font = .systemFont(ofSize: 16)

        // Setup brief text view
        briefTextView.isEditable = false
        briefTextView.isSelectable = false
        briefTextView.font = .systemFont(ofSize: 15)
        briefTextView.backgroundColor = .systemGray6
        briefTextView.layer.cornerRadius = 8
        briefTextView.layer.borderWidth = 1
        briefTextView.layer.borderColor = UIColor.systemGray4.cgColor
        briefTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        if currentProfile == nil {
            loadProfileFromFirestore()
        } else {
            applyProfileToUI()
        }
        
        profileImageView.applyCircleAvatarNoCrop()

        // Check if edit button should show
        checkIfOwnProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep profile image round
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.updateCircleMask()
    }

    // Hide edit button if not own profile
    private func checkIfOwnProfile() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        if let profile = currentProfile, profile.id != currentUserUID {
            editButton.isHidden = true
        }
    }

    // Load provider profile from firestore
    private func loadProfileFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert("No logged in user.")
            return
        }

        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

                let data = snap?.data() ?? [:]

                let profile = UserProfile(
                    id: uid,
                    fullName: data["fullName"] as? String ?? "",
                    contact: data["contact"] as? String ?? "",
                    imageURL: data["imageURL"] as? String,
                    role: .provider,
                    skills: data["skills"] as? [String] ?? [],
                    brief: data["brief"] as? String ?? "",
                    isSuspended: data["isSuspended"] as? Bool ?? false
                )

                self.currentProfile = profile
                self.applyProfileToUI()
                LocalUserStore.saveProfile(profile)
                self.checkIfOwnProfile()
            }
        }
    }
    
    // MARK: - Apply UI
    private func applyProfileToUI() {
        guard let profile = currentProfile else { return }

        nameLabel.text = profile.fullName
        contactLabel.text = profile.contact
        briefTextView.text = profile.brief

        showSkills(profile.skills ?? [])

        if let urlStr = profile.imageURL, let url = URL(string: urlStr) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    // Display skills as chips
    private func showSkills(_ skills: [String]) {
        skillsStackView.arrangedSubviews.forEach {
            skillsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if skills.isEmpty {
            skillsStackView.addArrangedSubview(makeChip(text: "No skills"))
            return
        }

        skills.forEach {
            skillsStackView.addArrangedSubview(makeChip(text: $0))
        }
    }

    // Create a skill chip label
    private func makeChip(text: String) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.horizontalPadding = 12
        label.verticalPadding = 6
        return label
    }

    // Label with padding support
    final class PaddingLabel: UILabel {
        var horizontalPadding: CGFloat = 12
        var verticalPadding: CGFloat = 6

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )))
        }

        override var intrinsicContentSize: CGSize {
            let s = super.intrinsicContentSize
            return CGSize(
                width: s.width + horizontalPadding * 2,
                height: s.height + verticalPadding * 2
            )
        }
    }

    // Load profile image from url
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
        }.resume()
    }

    // Navigate to provider home page
    @IBAction func continueTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // Open edit profile screen
    @IBAction func editTapped(_ sender: UIButton) {
        guard let profile = currentProfile else { return }

        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "EditProfileViewController"
        ) as! EditProfileViewController

        vc.profile = profile

        vc.onSave = { [weak self] updated in
            self?.currentProfile = updated
            self?.applyProfileToUI()
            LocalUserStore.saveProfile(updated)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // Show alert message
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Profile", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
