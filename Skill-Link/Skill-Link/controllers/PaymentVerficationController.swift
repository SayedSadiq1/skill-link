//
//  PaymentVerficationController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//

import UIKit

class PaymentVerficationController : UIViewController {
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func navigateToRateProvider(_ sender: UIButton) {
        performSegue(withIdentifier: "rateProvider", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rateProvider" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }

}
