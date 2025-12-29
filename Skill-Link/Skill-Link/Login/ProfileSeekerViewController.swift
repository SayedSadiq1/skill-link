//
//  ProfileSeekerViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 28/12/2025.
//

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

    private var successBanner: UIView?
    private let db = Firestore.firestore()

    // holds loaded data
    private var currentProfile: SeekerProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Interests container styling (same as provider skills)
        interestsContainerView.layer.cornerRadius = 10
        interestsContainerView.layer.borderWidth = 1
        interestsContainerView.layer.borderColor = UIColor.systemGray4.cgColor

        // Contact container styling (same as provider)
        contactContainerView.layer.cornerRadius = 8
        contactContainerView.layer.borderWidth = 1
        contactContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        contactContainerView.backgroundColor = .white

        contactLabel.font = .systemFont(ofSize: 16)
        contactLabel.textColor = .label

        // Name styling
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

        // Load profile
        loadProfileFromFirestore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Firestore load
    private func loadProfileFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showSimpleAlert(title: "Error", message: "No logged in user. Please login again.")
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
                let imageURL = (data["imageURL"] as? String)

                // ✅ seeker uses interests (array)
                let interests = data["interests"] as? [String] ?? []

                self.currentProfile = SeekerProfile(
                    name: name,
                    interests: interests,
                    contact: contact,
                    imageURL: imageURL
                )

                self.applyProfileToUI()
            }
        }
    }

    // MARK: - Apply to UI
    private func applyProfileToUI() {
        guard let currentProfile else { return }

        nameLabel.text = currentProfile.name.isEmpty ? "No Name" : currentProfile.name
        contactLabel.text = currentProfile.contact.isEmpty ? "-" : currentProfile.contact

        showInterests(currentProfile.interests)

        if let urlString = currentProfile.imageURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    // MARK: - URL image loader
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

    // MARK: - Edit (optional, same idea as provider)
    @IBAction func editTapped(_ sender: UIButton) {
        guard let currentProfile else {
            showSimpleAlert(title: "Wait", message: "Profile not loaded yet.")
            return
        }

        let sb = UIStoryboard(name: "login", bundle: nil)

        guard let vc = sb.instantiateViewController(withIdentifier: "EditProfileSeekerViewController") as? EditProfileSeekerViewController else {
            fatalError("❌ Could not find EditProfileSeekerViewController in storyboard. Check Storyboard ID + Custom Class.")
        }

        // ✅ Pass seeker profile
        vc.profile = currentProfile

        // ✅ Callback after save
        vc.onSave = { [weak self] updated in
            guard let self else { return }
            self.currentProfile = updated
            self.applyProfileToUI()
            self.showSuccessBanner()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Interests chips (same as provider skills chips)
    private func showInterests(_ interests: [String]) {
        interestsStackView.arrangedSubviews.forEach {
            interestsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if interests.isEmpty {
            let chip = makeChip(text: "No interests")
            interestsStackView.addArrangedSubview(chip)
            return
        }

        for interest in interests {
            let chip = makeChip(text: interest)
            interestsStackView.addArrangedSubview(chip)
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

    // MARK: - Alerts
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Banner (same as provider)
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

// ✅ Simple model (kept separate from provider UserProfile so it doesn’t require brief/skills)
struct SeekerProfile {
    let name: String
    let interests: [String]
    let contact: String
    let imageURL: String?
}
