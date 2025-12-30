import UIKit

class BaseViewController: UIViewController {

    // Screens can override this and return false to hide the custom back button
    var shouldShowBackButton: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background image for all screens using this base class
        setBackgroundImage(named: "smaller_background")

        // Setup the navigation bar style for this screen
        setupNavigationItemStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Re-apply style when coming back to the screen (ios sometimes resets it)
        setupNavigationItemStyle()
    }

    private func setBackgroundImage(named name: String) {
        let bg = UIImageView(image: UIImage(named: name))
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false

        // Put it behind evreything
        view.insertSubview(bg, at: 0)

        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationItemStyle() {
        guard let navBar = navigationController?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Make nav bar transparent so background image shows
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        // Title style
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        // Large title style (if used)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = .white

        // This hides the default iOS back arrow (we are using our own)
        navigationItem.hidesBackButton = true

        // Show / hide the custom back button based on the screen need
        if shouldShowBackButton {
            navigationItem.leftBarButtonItem = makeBackButton()
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    private func makeBackButton() -> UIBarButtonItem {
        let backButton = UIBarButtonItem(
            title: "←",
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )

        // Style for the arrow text
        backButton.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)

        return backButton
    }

    @objc private func handleBack() {
        // Goes back one screen in the navigation stack
        navigationController?.popViewController(animated: true)
    }

    func addBottomBorder(
        to view: UIView,
        color: UIColor = .lightGray,
        height: CGFloat = 1
    ) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(border)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    func addTopBorder(
        to view: UIView,
        color: UIColor = .lightGray,
        height: CGFloat = 1
    ) {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(border)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.topAnchor.constraint(equalTo: view.topAnchor),
            border.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
