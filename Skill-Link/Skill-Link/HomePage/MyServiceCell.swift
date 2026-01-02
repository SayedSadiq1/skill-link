//
//  MyServiceCell.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 02/01/2026.
//
import UIKit

final class MyServiceCell: UITableViewCell {

    @IBOutlet weak var activeLabel: UILabel!      // the green "Active" label
    @IBOutlet weak var titleLabel: UILabel!       // "Professional Plumbing Service"
    @IBOutlet weak var categoryLabel: UILabel!    // "Plumbing"
    @IBOutlet weak var timeLabel: UILabel!        // "Morning - Afternoon" (or whatever)
    @IBOutlet weak var toggleButton: UIButton!    // red Disable button

    var onToggle: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(title: String, category: String, availableAt: String, available: Bool) {
        titleLabel.text = title
        categoryLabel.text = category
        timeLabel.text = availableAt

        if available {
            activeLabel.text = "Active"
            activeLabel.textColor = .systemGreen
            activeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            activeLabel.layer.cornerRadius = 6
            activeLabel.clipsToBounds = true

            toggleButton.setTitle("Disable", for: .normal)
            toggleButton.backgroundColor = .systemRed
            toggleButton.setTitleColor(.white, for: .normal)
            toggleButton.layer.cornerRadius = 6
            toggleButton.clipsToBounds = true
        } else {
            activeLabel.text = "Inactive"
            activeLabel.textColor = .systemRed
            activeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            activeLabel.layer.cornerRadius = 6
            activeLabel.clipsToBounds = true

            toggleButton.setTitle("Enable", for: .normal)
            toggleButton.backgroundColor = .systemGreen
            toggleButton.setTitleColor(.white, for: .normal)
            toggleButton.layer.cornerRadius = 6
            toggleButton.clipsToBounds = true
        }
    }

    @IBAction func toggleTapped(_ sender: UIButton) {
        onToggle?()
    }
}
