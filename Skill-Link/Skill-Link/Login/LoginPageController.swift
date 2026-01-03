import UIKit
import FirebaseAuth
import FirebaseFirestore

final class LoginPageController: BaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 static var loggedinUser: UserProfile?
    private let db = Firestore.firestore()
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
    }

    // MARK: - Login
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Login", message: "Please enter email and password.")
            return
        }

        sender.isEnabled = false
        setLoading(true)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error {
                self.finish(sender)
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            guard let uid = result?.user.uid else {
                self.finish(sender)
                self.showAlert(title: "Login Failed", message: "Missing user id.")
                return
            }

            self.loadUser(uid: uid, sender: sender)
        }
    }

    // MARK: - Load user
    private func loadUser(uid: String, sender: UIButton) {
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error {
                self.finish(sender)
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                try? Auth.auth().signOut()
                LocalUserStore.clearProfile()
                self.finish(sender)
                return
            }

            let isSuspended = data["isSuspended"] as? Bool ?? false
            if isSuspended {
                try? Auth.auth().signOut()
                LocalUserStore.clearProfile()
                self.finish(sender)
                self.showAlert(
                    title: "Account Suspended",
                    message: "Your account has been suspended."
                )
                return
            }

            let roleString = (data["role"] as? String ?? "").lowercased()
            guard let role = UserRole(rawValue: roleString) else {
                self.finish(sender)
                self.showAlert(title: "Error", message: "User role not set.")
                return
            }

            let profile = UserProfile(
                id: uid,
                fullName: data["fullName"] as? String ?? "",
                contact: data["contact"] as? String ?? "",
                imageURL: data["imageURL"] as? String,
                role: role,
                skills: role == .provider
                    ? (data["skills"] as? [String] ?? [])
                    : (data["interests"] as? [String] ?? []),
                brief: data["brief"] as? String ?? "",
                isSuspended: false
            )

            LocalUserStore.saveProfile(profile)
            LoginPageController.loggedinUser = profile

            self.finish(sender) {
                role == .provider ? self.goToProviderHome() : self.goToSeekerHome()
            }
        }
    }

    // MARK: - Navigation
    private func goToProviderHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        navigationController?.setViewControllers([vc], animated: true)
    }

    private func goToSeekerHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        navigationController?.setViewControllers([vc], animated: true)
    }

    // MARK: - Spinner
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        view.isUserInteractionEnabled = !loading
    }

    private func finish(_ sender: UIButton, completion: (() -> Void)? = nil) {
        setLoading(false)
        sender.isEnabled = true
        completion?()
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
