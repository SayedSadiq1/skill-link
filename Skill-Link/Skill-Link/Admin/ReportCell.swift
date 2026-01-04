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

    var onReviewTapped: (() -> Void)?

    @IBAction func reviewTapped(_ sender: UIButton) {
        onReviewTapped?()
    }

    func configure(with report: ReportModel) {
        titleLabel.text = "Reported by: \(report.userName)"
        serviceLabel.text = "Service: \(report.serviceName)"
        reasonLabel.text = "Reason: \(report.reason)"
        statusLabel.text = "Status: \(report.status)"

        reviewButton.setTitle(
            report.status == "Pending" ? "Review" : "Reviewed",
            for: .normal
        )
        reviewButton.isEnabled = report.status == "Pending"
    }
}
