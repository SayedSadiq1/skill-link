import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileSeekerViewController: BaseViewController {

    @IBOutlet weak var interestsStackView: UIStackView!
    @IBOutlet weak var interestsContainerView: UIView!

    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var contactLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    private var successBanner: UIView?
    private let db = Firestore.firestore()

    private var currentProfile: SeekerProfile?

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.applyCircleAvatarNoCrop()
        
        interestsContainerView.layer.cornerRadius = 10
        interestsContainerView.layer.borderWidth = 1
        interestsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        setupInterestsStackView()

        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)

        loadProfileFromFirestore()
        
       
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
           profileImageView.clipsToBounds = true
           profileImageView.contentMode = .scaleAspectFill
        profileImageView.updateCircleMask()
    }

    private func setupInterestsStackView() {
        interestsStackView.axis = .horizontal
        interestsStackView.alignment = .center
        interestsStackView.spacing = 8
        interestsStackView.isLayoutMarginsRelativeArrangement = true
        interestsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }

    // MARK: - Firestore
    private func loadProfileFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("User").document(uid).getDocument { [weak self] snap, _ in
            guard let self else { return }

            let data = snap?.data() ?? [:]

            self.currentProfile = SeekerProfile(
                name: data["fullName"] as? String ?? "",
                interests: data["interests"] as? [String] ?? [],
                contact: data["contact"] as? String ?? "",
                imageURL: data["imageURL"] as? String
            )

            self.applyProfileToUI()
            self.saveUserProfileLocally()
        }
    }

    private func applyProfileToUI() {
        guard let currentProfile else { return }

        nameLabel.text = currentProfile.name
        contactLabel.text = currentProfile.contact
        showInterests(currentProfile.interests)

        if let urlStr = currentProfile.imageURL, let url = URL(string: urlStr) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.profileImageView.image = img }
        }.resume()
    }

    // MARK: - LOCAL SAVE (FIXED)
    private func saveUserProfileLocally() {
        guard
            let currentProfile,
            let uid = Auth.auth().currentUser?.uid
        else { return }

        let profile = UserProfile(
            id: uid,
            name: currentProfile.name,
            contact: currentProfile.contact,
            imageURL: currentProfile.imageURL,
            role: .seeker,
            skills: currentProfile.interests,
            brief: "",
            isSuspended: false
        )

        LocalUserStore.saveProfile(profile)
    }

    // MARK: - Chips
    private func showInterests(_ interests: [String]) {
        interestsStackView.arrangedSubviews.forEach {
            interestsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let list = interests.isEmpty ? ["No interests"] : interests
        list.forEach { interestsStackView.addArrangedSubview(makeChip(text: $0)) }
    }

    private func makeChip(text: String) -> UILabel {
        let label = PaddingLabel()
        label.text = text
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
            super.drawText(in: rect.inset(by: UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )))
        }

        override var intrinsicContentSize: CGSize {
            let s = super.intrinsicContentSize
            return CGSize(width: s.width + horizontalPadding * 2,
                          height: s.height + verticalPadding * 2)
        }
    }

    // MARK: - Continue
    @IBAction func continueTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Edit
    @IBAction func editTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "EditProfileSeekerViewController") as! EditProfileSeekerViewController
        vc.profile = currentProfile
        vc.onSave = { [weak self] updated in
            self?.currentProfile = updated
            self?.applyProfileToUI()
            self?.saveUserProfileLocally()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

struct SeekerProfile {
    let name: String
    let interests: [String]
    let contact: String
    let imageURL: String?
}
