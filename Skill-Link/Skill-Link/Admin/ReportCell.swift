//
//  ReportCell.swift
//  Skill-Link
//
//  Created by Sayed Sadiq on 22/12/2025.
//

import UIKit

class ReportCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var reviewButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        reviewButton.layer.cornerRadius = 12
        reviewButton.clipsToBounds = true
    }

    func configure(with report: ReportsController.Report) {
        titleLabel.text = report.title
        serviceLabel.text = "Reported Service: \(report.service)"
        reasonLabel.text = "Reason: \(report.reason)"
        statusLabel.text = "Status: \(report.status)"
    }
}
