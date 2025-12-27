//
//  RateFormController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//
import UIKit

class RateFormController : BaseViewController {
    
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!

    private var stars: [UIButton] {
        [star1, star2, star3, star4, star5]
    }

    
    var message: String?
    var rating: Int?
    var serviceID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewField.layer.cornerRadius = 24
        reviewField.layer.borderWidth = 2
        reviewField.layer.borderColor = UIColor.black.cgColor
        submitButton.backgroundColor = UIColor(hex: "#182E61")
        submitButton.layer.cornerRadius = 12
    }
    
    func setStarsImage(buttonNumber: Int){
        for i in 0..<buttonNumber {
            stars[i].setImage(UIImage(named: "starfill"), for: .normal)
        }
        if buttonNumber >= 1 && buttonNumber <= 5 {
            for i in buttonNumber..<5 {
                stars[i].setImage(UIImage(named: "star"), for: .normal)
         }
        }
        print(buttonNumber)
        rating = buttonNumber
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        guard let index = stars.firstIndex(of: sender) else { return }
            let selectedRating = index + 1
            setStarsImage(buttonNumber: selectedRating)
    }
    @IBAction func submitTapped() {
        
        Task {
            try await ReviewController.shared.makeReview(senderName: /*will fix when auth is implemeted*/"", ServiceID: self.serviceID ?? "", content: self.reviewField.text!, rating: self.rating ?? 0)
        }
    }
    
}
