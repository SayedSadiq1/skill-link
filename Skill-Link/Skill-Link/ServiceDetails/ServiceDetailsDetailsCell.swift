//
//  ServiceDetailsDetailsCell.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class ServiceDetailsDetailsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
