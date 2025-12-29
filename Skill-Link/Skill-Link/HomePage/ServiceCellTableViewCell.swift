//
//  ServiceCellTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

class ServiceCellTableViewCell: UITableViewCell {
        @IBOutlet weak var serviceNameLabel: UILabel!
        @IBOutlet weak var priceLabel: UILabel!
        @IBOutlet weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
