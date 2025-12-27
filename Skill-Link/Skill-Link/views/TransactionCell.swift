//
//  TransactionCell.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

import UIKit

class TransactionCell : UITableViewCell {
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var containerView: UIStackView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
        
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
       }

       func configure(with transaction: Transaction) {
           serviceLabel.text = "Payment - " + transaction.serviceName
           paymentMethodLabel.text = "Paid via: "+transaction.method
           dateLabel.text = transaction.createdAt
           amountLabel.text = String(format: "%.2f BD", transaction.amount)
       }
}
