import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RoleSelectionViewController: BaseViewController {

    @IBOutlet weak var providerCardView: UIView!
    @IBOutlet weak var seekerCardView: UIView!

    private let db = Firestore.firestore()
    private var isSaving = false

    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // block going back from here
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // style cards same as figma
        styleCard(providerCardView)
        styleCard(seekerCardView)
    }

    // MARK: - Card Style
    private func styleCard(_ view: UIView) {
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = false

        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
    }

    // MARK: - Actions
    @IBAction func providerTapped(_ sender: UIButton) {
        setRole("provider")
    }

    @IBAction func seekerTapped(_ sender: UIButton) {
        setRole("seeker")
    }

    // MARK: - Save role
    private func setRole(_ role: String) {
        guard !isSaving else { return }

        guard let user = Auth.auth().currentUser else {
            showAlert("You are not logged in. Please login again.")
            return
        }

        isSaving = true

        let data: [String: Any] = [
            "role": role,
            "profileCompleted": false
        ]

        db.collection("User").document(user.uid).setData(data, merge: true) { [weak self] error in
            guard let self else { return }
            self.isSaving = false

            if let error = error {
                self.showAlert("Failed to save role: \(error.localizedDescription)")
                return
            }

            // update role locally in the saved profile
            self.updateRoleLocally(role, uid: user.uid)

            // navigation still handled by storyboard
        }
    }

    // MARK: - Local update
    private func updateRoleLocally(_ role: String, uid: String) {
        // load existing local profile
        guard var profile = LocalUserStore.loadProfile() else { return }

        // make sure uid is set
        profile.id = uid

        // role will be resolved later from firestore
        // we just keep uid synced here
        LocalUserStore.saveProfile(profile)
    }

    // MARK: - Alert
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Role Selection", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
