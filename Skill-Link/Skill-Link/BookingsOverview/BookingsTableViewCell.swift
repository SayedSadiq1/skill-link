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
    func goToServiceDetails(for serviceId: String)
    func markServiceCompleted(for booking: Booking)
    func goToProviderProfile(for providerId: String)
    func markServiceCanceled(for booking: Booking)
}

class BookingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var approveDeclineButtons: UIStackView!
    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var bookingCategory: UILabel!
    @IBOutlet weak var providedBy: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var price: UILabel!
    var booking: Booking?
    private let isProvider = (LoginPageController.loggedinUser?.isProvider ?? true)
    
    @IBOutlet weak var cellContextMenu: UIButton!
    weak var delegate: BookingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if !isProvider {
            if approveDeclineButtons != nil {
                approveDeclineButtons.isHidden = true
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupContextMenu(state: BookedServiceStatus) {
        if cellContextMenu == nil {
            return
        }
        
        let closure = {[weak self] (action : UIAction) in
            print(action.title)
            switch action.title {
            case "See Details":
                self!.delegate?.goToServiceDetails(for: self!.booking!.serviceId)
            case "Mark Completed":
                self!.delegate?.markServiceCompleted(for: self!.booking!)
            case "View Provider":
                self!.delegate?.goToProviderProfile(for: self!.booking!.providerId)
            case "Cancel":
                self!.delegate?.markServiceCanceled(for: self!.booking!)
            case "Favorite":
                print("")
            case "Rate":
                print("")
            default:
                print("impossible")
            }
        }
        
        
        switch state {
        case .Upcoming:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details", attributes: [], handler: closure),
                isProvider ? UIAction(title: "Mark Completed", handler: closure) : UIAction(title: "View Provider", handler: closure),
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
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        let phoneNumber = "+97332324545" // Your phone number
        
        // Remove spaces, dashes, etc.
        let cleanNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        // Create the URL
        guard let url = URL(string: "tel://\(cleanNumber)") else { return }
        
        // Check if device can open phone app (not iPad/iPod)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
