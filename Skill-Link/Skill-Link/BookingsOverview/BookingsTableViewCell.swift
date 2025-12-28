//
//  UpcomingTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 18/12/2025.
//

import UIKit

protocol BookingsTableViewCellDelegate: AnyObject {
    func didTapApprove(for serviceId: UUID)
    func didTapDecline(for serviceId: UUID)
}

class BookingsTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var bookingCategory: UILabel!
    @IBOutlet weak var providedBy: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var price: UILabel!
    var serviceId: UUID!
    
    weak var delegate: BookingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func approveBtnTap(_ sender: UIButton) {
        delegate?.didTapApprove(for: serviceId)
    }
    
    @IBAction func declineBtnTap(_ sender: UIButton) {
        delegate?.didTapDecline(for: serviceId)
    }
}
