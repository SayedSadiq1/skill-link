//
//  TransactionCell.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var parentView: UIView!
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.current
        formatter.timeZone = .current
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layoutMargins = UIEdgeInsets( top: 12,left: 0,bottom: 12,right: 0)
        parentView.layer.cornerRadius = 16
    }

    func configure(with transaction: Transaction) {
        serviceLabel.text = "Payment - \(transaction.serviceName)"
        paymentMethodLabel.text = "Paid via: \(transaction.method)"
        dateLabel.text = Self.dateFormatter.string(from: transaction.createdAt)
        amountLabel.text = String(format: "%.2f BD", transaction.amount)
    }
}
