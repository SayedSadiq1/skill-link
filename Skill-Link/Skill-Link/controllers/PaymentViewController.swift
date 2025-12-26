//
//  PaymentViewController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//
import UIKit

class PaymentViewController: BaseViewController {
    
    @IBOutlet weak var totalContainer: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var taxlabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!
    
    var isCashOnDelivery: Bool = false
    var tax: Double = 10.0
    var servicePrice: Double = 0.0
    var totalPrice: Double = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTopBorder(to: totalContainer, color: UIColor(hex:"#E8DEF8"), height: 3)
        paymentButton.setTitle(isCashOnDelivery ? "Confirm" : "Pay Now", for: .normal)
        print(isCashOnDelivery)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "paymentVerfication" {
            segue.destination.modalPresentationStyle = .fullScreen
        }
    }

}

