//
//  NextBookingCellTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-212-20 on 03/01/2026.
//

// NextBookingCellTableViewCell.swift
import UIKit

final class NextBookingCellTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var viewDetailsButton: UIButton!

    var onViewDetails: (() -> Void)?

    @IBAction func viewDetailsTapped(_ sender: Any) {
        onViewDetails?()
    }

    func configureNoBooking() {
        titleLabel.text = "No upcoming bookings"
        subtitleLabel.text = ""
        viewDetailsButton.isHidden = true
        onViewDetails = nil
    }

    func configureBooking(status: String, subtitle: String, onViewDetails: @escaping () -> Void) {
        titleLabel.text = "Status: \(status)"
        subtitleLabel.text = subtitle
        viewDetailsButton.isHidden = false
        self.onViewDetails = onViewDetails
    }
}
