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
            
            // Style the button - GREY initially
            button.layer.cornerRadius = 25
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.clear.cgColor
            button.backgroundColor = UIColor.systemGray5  // Grey background
            
            // Set text color if button has text
            button.setTitleColor(.darkGray, for: .normal)
            button.tintColor = .darkGray
            
            // Add tap action PROGRAMMATICALLY
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            print("✅ Setup button with tag: \(tag) (\(interestNames[tag] ?? "unknown"))")
        }
        
        // Setup continue button
        continueButton?.layer.cornerRadius = 12
        continueButton?.backgroundColor = UIColor(red: 0/255, green: 48/255, blue: 120/255, alpha: 1.0)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let tag = sender.tag
        
        print("🔵🔵🔵 BUTTON TAPPED! Tag: \(tag) 🔵🔵🔵")
        
        guard let interestName = interestNames[tag] else {
            print("❌ Unknown tag")
            return
        }
        
        print("Interest: \(interestName)")
        
        // Toggle selection
        if selectedInterests.contains(tag) {
            // Deselect
            selectedInterests.remove(tag)
            print("❌ Deselected: \(interestName)")
            updateButton(sender, isSelected: false)
        } else {
            // Select
            if selectedInterests.count < maxSelection {
                selectedInterests.insert(tag)
                print("✅ Selected: \(interestName)")
                updateButton(sender, isSelected: true)
            } else {
                print("⚠️ Max selection reached")
                showAlert()
            }
        }
        
        print("Total selected: \(selectedInterests.count)")
    }
    
    private func updateButton(_ button: UIButton, isSelected: Bool) {
        print("Updating button \(button.tag) - selected: \(isSelected)")
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            if isSelected {
                // SKY BLUE background with blue stroke
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)  // Light sky blue
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.layer.borderWidth = 2
                
                // Blue text/icon
                button.setTitleColor(.systemBlue, for: .normal)
                button.tintColor = .systemBlue
                
                // Optional: slight scale effect
                button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
            } else {
                // GREY background with no stroke
                button.backgroundColor = UIColor.systemGray5
                button.layer.borderColor = UIColor.clear.cgColor
                
                // Dark grey text/icon
                button.setTitleColor(.darkGray, for: .normal)
                button.tintColor = .darkGray
                
                // Reset scale
                button.transform = .identity
            }
        }
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
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let selectedNames = selectedInterests.compactMap { interestNames[$0] }
        print("Continue tapped with: \(selectedNames)")
        
        if selectedInterests.isEmpty {
            let alert = UIAlertController(
                title: "No Selection",
                message: "Please select at least one interest.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // TODO: Navigate to next screen
            print("✅ Continuing with: \(selectedNames)")
            
            // Example: Navigate to next screen
            // performSegue(withIdentifier: "showNextScreen", sender: self)
        }
    }
}
