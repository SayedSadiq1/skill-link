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
            
            // Style the button
            button.layer.cornerRadius = 25
            button.layer.borderWidth = 0
            
            // Remove any background images
            button.setBackgroundImage(nil, for: .normal)
            button.setBackgroundImage(nil, for: .selected)
            button.setBackgroundImage(nil, for: .highlighted)
            
            // Force set grey background (this will override Storyboard)
            let grey = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            button.backgroundColor = grey
            
            // Set text color
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
        
        // Remove any background images that might block color changes
        button.setBackgroundImage(nil, for: .normal)
        button.setBackgroundImage(nil, for: .selected)
        button.setBackgroundImage(nil, for: .highlighted)
        
        if isSelected {
            // SKY BLUE fill (#38A1FF)
            let skyBlue = UIColor(red: 56/255, green: 161/255, blue: 255/255, alpha: 1.0)
            button.backgroundColor = skyBlue
            button.layer.borderWidth = 0
            
            // White text
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.white, for: .highlighted)
            button.tintColor = .white
            
            print("✅ Changed to SKY BLUE")
            
        } else {
            // GREY fill
            let grey = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            button.backgroundColor = grey
            button.layer.borderWidth = 0
            
            // Dark grey text
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitleColor(.darkGray, for: .highlighted)
            button.tintColor = .darkGray
            
            print("✅ Changed to GREY")
        }
        
        // Force layout update
        button.layoutIfNeeded()
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
