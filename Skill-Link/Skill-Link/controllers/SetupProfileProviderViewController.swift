import UIKit

class SetupProfileProviderViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var briefTextView: UITextView!

    private let briefPlaceholder = "Brief..."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBriefTextView()
    }

    private func setupBriefTextView() {
        // UI styling
        briefTextView.layer.cornerRadius = 10
        briefTextView.layer.borderWidth = 1
        briefTextView.layer.borderColor = UIColor.systemGray4.cgColor
        briefTextView.clipsToBounds = true

        // Placeholder setup
        briefTextView.text = briefPlaceholder
        briefTextView.textColor = .lightGray
        briefTextView.delegate = self
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == briefPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = briefPlaceholder
            textView.textColor = .lightGray
        }
    }
}
