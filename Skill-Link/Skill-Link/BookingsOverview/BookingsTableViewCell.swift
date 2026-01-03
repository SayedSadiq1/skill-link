//
//  UpcomingTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 18/12/2025.
//

import UIKit

protocol BookingsTableViewCellDelegate: AnyObject {
    func didTapApprove(for booking: Booking)
    func didTapDecline(for booking: Booking)
}

class BookingsTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var bookingCategory: UILabel!
    @IBOutlet weak var providedBy: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var price: UILabel!
    var booking: Booking?
    
    @IBOutlet weak var cellContextMenu: UIButton!
    weak var delegate: BookingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupContextMenu(state: BookedServiceStatus) {
        if cellContextMenu == nil {
            return
        }
        
        let closure = {(action : UIAction) in
            print(action.title)
        }
        
        
        switch state {
        case .Upcoming:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details", attributes: [], handler: closure),
                UIAction(title: "View Provider", handler: closure),
                UIAction(title: "Cancel", handler: closure)
            ])
            
        case .Completed:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details", state: .off, handler: closure),
                UIAction(title: "Favorite", image: UIImage(systemName: "star"), handler: closure),
                UIAction(title: "Rate", handler: closure)
            ])
        default:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details", state: .off, handler: closure)
            ])
        }
        
        cellContextMenu.showsMenuAsPrimaryAction = true
        cellContextMenu.changesSelectionAsPrimaryAction = false
    }

    @IBAction func approveBtnTap(_ sender: UIButton) {
        print("approveBtnTap")
        delegate?.didTapApprove(for: booking!)
    }
    
    @IBAction func declineBtnTap(_ sender: UIButton) {
        print("declineBtnTap")
        delegate?.didTapDecline(for: booking!)
    }
}
