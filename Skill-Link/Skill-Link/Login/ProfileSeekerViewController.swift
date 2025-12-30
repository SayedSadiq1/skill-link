import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileSeekerViewController: BaseViewController {

    // Interests container (same as skills container)
    @IBOutlet weak var interestsStackView: UIStackView!
    @IBOutlet weak var interestsContainerView: UIView!

    // Contact container
    @IBOutlet weak var contactContainerView: UIView!
    @IBOutlet weak var contactLabel: UILabel!

    // Name + image
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    private var successBanner: UIView?  // For showing success banner after profile update
    private let db = Firestore.firestore()  // Firestore reference for saving/loading data

    // Holds the current profile data
    private var currentProfile: SeekerProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UI for interests and contact containers
        interestsContainerView.layer.cornerRadius = 10
        interestsContainerView.layer.borderWidth = 1
        interestsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        contactLabel.font = .systemFont(ofSize: 16)
        contactLabel.textColor = .label

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

        // Load profile data from Firestore
        loadProfileFromFirestore()
    }
    
    override var shouldShowBackButton: Bool { false }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make profile image a circle
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Firestore Load
    private func loadProfileFromFirestore() {
        // Get current user UID
        guard let uid = Auth.auth().currentUser?.uid else {
            showSimpleAlert(title: "Error", message: "No logged in user. Please login again.")
            return
        }

        // Fetch user profile from Firestore
        db.collection("User").document(uid).getDocument { [weak self] snap, err in
            guard let self else { return }

            DispatchQueue.main.async {
                if let err = err {
                    self.showSimpleAlert(title: "Error", message: "Failed to load profile: \(err.localizedDescription)")
                    return
                }

                // Parse Firestore data
                let data = snap?.data() ?? [:]
                let name = (data["fullName"] as? String ?? "")
                let contact = (data["contact"] as? String ?? "")
                let imageURL = (data["imageURL"] as? String)

                // Seeker uses interests (array)
                let interests = data["interests"] as? [String] ?? []

                // Populate the current profile with data
                self.currentProfile = SeekerProfile(
                    name: name,
                    interests: interests,
                    contact: contact,
                    imageURL: imageURL
                )

                // Apply the profile data to the UI
                self.applyProfileToUI()

                // Save the profile data locally
                self.saveUserProfileLocally()
            }
        }
    }

    // MARK: - Apply Profile to UI
    private func applyProfileToUI() {
        guard let currentProfile else { return }

        // Update labels with the loaded data
        nameLabel.text = currentProfile.name.isEmpty ? "No Name" : currentProfile.name
        contactLabel.text = currentProfile.contact.isEmpty ? "-" : currentProfile.contact

        // Display the interests
        showInterests(currentProfile.interests)

        // Load the profile image if available
        if let urlString = currentProfile.imageURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")  // Default image
        }
    }

    // MARK: - URL Image Loader
    private func loadImage(from url: URL) {
        // Set default image while loading
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
        }.resume()
    }

    // MARK: - Save Profile Locally
    private func saveUserProfileLocally() {
        // Save the current profile data locally using UserDefaults
        guard let currentProfile else { return }

        let userProfile = UserProfile(
            name: currentProfile.name,
            skills: currentProfile.interests,
            brief: "",  // No brief for seeker profile
            contact: currentProfile.contact,
            imageURL: currentProfile.imageURL,
            id: Auth.auth().currentUser?.uid
        )

        // Encode and save the profile to UserDefaults
        if let encodedProfile = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }

    // MARK: - Interests Chips
    private func showInterests(_ interests: [String]) {
        interestsStackView.arrangedSubviews.forEach {
            interestsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // If no interests, show a placeholder chip
        if interests.isEmpty {
            let chip = makeChip(text: "No interests")
            interestsStackView.addArrangedSubview(chip)
            return
        }

        // Create and display chips for each interest
        for interest in interests {
            let chip = makeChip(text: interest)
            interestsStackView.addArrangedSubview(chip)
        }
    }

    private func makeChip(text: String) -> UILabel {
        // Create a styled label for each interest chip
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

    // MARK: - Continue Button Action
    @IBAction func continueTapped(_ sender: UIButton) {
        // Check if current profile is loaded
        guard let currentProfile else {
            showSimpleAlert(title: "Wait", message: "Profile not loaded yet.")
            return
        }

        // Navigate to the Seeker Home page
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        if let seekerHomeVC = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController") as? SeekerHomeViewController {
            // You can pass any necessary data to the home page here (if needed)
            navigationController?.pushViewController(seekerHomeVC, animated: true)
        }
    }

    // MARK: - Edit Profile
    @IBAction func editTapped(_ sender: UIButton) {
        guard let currentProfile else {
            showSimpleAlert(title: "Wait", message: "Profile not loaded yet.")
            return
        }

        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "EditProfileSeekerViewController") as? EditProfileSeekerViewController else {
            fatalError("Could not find EditProfileSeekerViewController in storyboard.")
        }

        // Pass current seeker profile to the next screen
        vc.profile = currentProfile

        // Callback after saving the profile from the edit screen
        vc.onSave = { [weak self] updated in
            guard let self else { return }
            self.currentProfile = updated
            self.applyProfileToUI()  // Apply the updated profile data to the UI
            self.showSuccessBanner()  // Show success banner
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Alerts
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Success Banner
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

// Simple model for seeker profile
struct SeekerProfile {
    let name: String
    let interests: [String]
    let contact: String
    let imageURL: String?
}
