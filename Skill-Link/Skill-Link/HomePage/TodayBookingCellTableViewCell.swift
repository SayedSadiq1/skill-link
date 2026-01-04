//
//  TodayBookingCellTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 04/01/2026.
//
// TodayBookingCellTableViewCell.swift
// TodayBookingCellTableViewCell.swift
import UIKit

final class TodayBookingCellTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!

    var onViewDetails: (() -> Void)?
    var onChat: (() -> Void)?

    @IBAction func viewDetailsTapped(_ sender: Any) { onViewDetails?() }
    @IBAction func chatTapped(_ sender: Any) { onChat?() }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        seekerNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        categoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        [seekerNameLabel, categoryLabel, timeLabel, priceLabel].forEach { l in
            l?.numberOfLines = 1
            l?.lineBreakMode = .byTruncatingTail
            l?.adjustsFontSizeToFitWidth = true
            l?.minimumScaleFactor = 0.75
        }

        viewDetailsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        chatButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    func configureBooking(seekerName: String, category: String, timeText: String, priceText: String) {
        seekerNameLabel.text = seekerName
        categoryLabel.text = category
        timeLabel.text = timeText
        priceLabel.text = priceText

        viewDetailsButton.isHidden = false
        chatButton.isHidden = false
    }
}
