import UIKit
import FirebaseAuth
import FirebaseFirestore

// Handles login screen logic and navigation
final class LoginPageController: BaseViewController {

    // Email input field
    @IBOutlet weak var emailTextField: UITextField!

    // Password input field
    @IBOutlet weak var passwordTextField: UITextField!

    // Holds logged in user profile
    static var loggedinUser: UserProfile?

    // Firestore reference
    private let db = Firestore.firestore()

    // Spinner shown during loading
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
    }

    // Triggered when login button pressed
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        // Validate input values
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Login", message: "Please enter email and password.")
            return
        }

        sender.isEnabled = false
        setLoading(true)

        // Firebase email login
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error {
                self.finish(sender)
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            // Get logged in user id
            guard let uid = result?.user.uid else {
                self.finish(sender)
                self.showAlert(title: "Login Failed", message: "Missing user id.")
                return
            }

            // Load user profile from firestore
            self.loadUser(uid: uid, sender: sender)
        }
    }

    // Loads user data after login
    private func loadUser(uid: String, sender: UIButton) {
        db.collection("User").document(uid).getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error {
                self.finish(sender)
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            // Check if user document exist
            guard let data = snap?.data() else {
                try? Auth.auth().signOut()
                LocalUserStore.clearProfile()
                self.finish(sender)
                return
            }

            // Check if account is suspended
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

            // Read user role from data
            let roleString = (data["role"] as? String ?? "").lowercased()
            guard let role = UserRole(rawValue: roleString) else {
                self.finish(sender)
                self.showAlert(title: "Error", message: "User role not set.")
                return
            }

            // Build local user profile model
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

            // Save user data locally
            LocalUserStore.saveProfile(profile)
            LoginPageController.loggedinUser = profile

            // Navigate based on user role
            self.finish(sender) {
                role == .provider ? self.goToProviderHome() : self.goToSeekerHome()
            }
        }
    }

    // Navigate to provider home screen
    private func goToProviderHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProviderHomeViewController")
        navigationController?.setViewControllers([vc], animated: true)
    }

    // Navigate to seeker home screen
    private func goToSeekerHome() {
        let sb = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")
        navigationController?.setViewControllers([vc], animated: true)
    }

    // Setup loading spinner in center
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Enable or disable loading state
    private func setLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        view.isUserInteractionEnabled = !loading
    }

    // Finish loading and re-enable button
    private func finish(_ sender: UIButton, completion: (() -> Void)? = nil) {
        setLoading(false)
        sender.isEnabled = true
        completion?()
    }

    // Shows simple alert message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
