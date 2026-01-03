//
//  ServiceDetailsProviderCell.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class ServiceDetailsProviderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var providerContactLabel: UILabel!
    var parent: UIViewController?
    var providerId: String?
    let userManager = FirebaseService.shared
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
