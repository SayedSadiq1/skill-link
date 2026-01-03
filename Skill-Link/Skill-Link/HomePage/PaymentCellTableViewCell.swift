//
//  PaymentCellTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-212-20 on 03/01/2026.
//

import UIKit

final class PaymentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // nice card look if your cell has a container view; otherwise keep simple
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }

    func configure(userText: String, dateText: String, amount: Double, method: String) {
        titleLabel.text = "Payment - \(userText)"
        methodLabel.text = "Paid via: \(method)"
        dateLabel.text = dateText
        amountLabel.text = String(format: "+%.2f BD", amount)
    }
}
