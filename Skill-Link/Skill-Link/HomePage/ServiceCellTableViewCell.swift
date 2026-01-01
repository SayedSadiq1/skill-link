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
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    var serviceData: Service? = nil
    var parent: UIViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func viewDetailsClick(_ sender: Any) {
        print("jhtyuskjhdgfytsduijhgfdtsrweyuirgjhfvdgy7eurhfj")
        if serviceData != nil {
            let serviceDetailsStoryboard = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
            if let serviceDetails = serviceDetailsStoryboard.instantiateViewController(withIdentifier: "serviceDetailsPage") as? ServiceDetailsViewController {
                serviceDetails.service = serviceData
                parent!.navigationController?.pushViewController(serviceDetails, animated: true)
            }
        }
    }
}
