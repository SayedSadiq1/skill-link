import UIKit

class SelectInterstViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedInterests: Set<Int> = []
    private let maxSelection = 3
    
    // Interest names mapped to tags
    private let interestNames: [Int: String] = [
        1: "Crypto Trading",
        2: "Graphic Design",
        3: "Teaching",
        4: "Cleaning",
        5: "Electrician",
        6: "Carpenter",
        7: "Plumbing"
    ]
    
    // MARK: - IBOutlets
    @IBOutlet weak var cryptoTradingButton: UIButton!
    @IBOutlet weak var graphicDesignButton: UIButton!
    @IBOutlet weak var teachingButton: UIButton!
    @IBOutlet weak var cleaningButton: UIButton!
    @IBOutlet weak var electricianButton: UIButton!
    @IBOutlet weak var carpenterButton: UIButton!
    @IBOutlet weak var plumbingButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ View loaded")
        
        setupAllButtons()
    }
    
    private func setupAllButtons() {
        // Get all interest buttons with their tags
        let buttons: [(button: UIButton?, tag: Int)] = [
            (cryptoTradingButton, 1),
            (graphicDesignButton, 2),
            (teachingButton, 3),
            (cleaningButton, 4),
            (electricianButton, 5),
            (carpenterButton, 6),
            (plumbingButton, 7)
        ]
        
        // Setup each button
        for (button, tag) in buttons {
            guard let button = button else {
                print("❌ Button is nil!")
                continue
            }
            
            // Set the tag
            button.tag = tag
            
            // Remove any background images
            button.setBackgroundImage(nil, for: .normal)
            button.setBackgroundImage(nil, for: .selected)
            button.setBackgroundImage(nil, for: .highlighted)
            
            // Set text color
            button.setTitleColor(.darkGray, for: .normal)
            button.tintColor = .darkGray
            
            print("✅ Setup button with tag: \(tag) (\(interestNames[tag] ?? "unknown"))")
        }
        
        // Setup continue button
        continueButton?.layer.cornerRadius = 12
        continueButton?.backgroundColor = UIColor(red: 0/255, green: 48/255, blue: 120/255, alpha: 1.0)
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Maximum Reached",
            message: "You can only select \(maxSelection) interests.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @IBAction func buttonTapped(_ sender: InterestButton) {
        sender.toggle()
    }
}
