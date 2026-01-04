//
//  UpcomingTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 18/12/2025.
//

import UIKit

protocol BookingsTableViewCellDelegate: AnyObject {
    func didTapApprove(for serviceId: String)
    func didTapDecline(for serviceId: String)
    func didTapRate(for serviceId: String)
    func didTapSeeDetails(for serviceId: String)
    func didTapFavorite(for serviceId: String)
}


class BookingsTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var bookingCategory: UILabel!
    @IBOutlet weak var providedBy: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var price: UILabel!
    var serviceId: String!
    
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
        guard cellContextMenu != nil else { return }

        switch state {
        case .Upcoming:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details") { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.didTapSeeDetails(for: self.serviceId)
                },
                UIAction(title: "View Provider") { _ in },
                UIAction(title: "Cancel") { _ in }
            ])

        case .Completed:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details") { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.didTapSeeDetails(for: self.serviceId)
                },
                UIAction(title: "Favorite", image: UIImage(systemName: "star")) { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.didTapFavorite(for: self.serviceId)
                },
                UIAction(title: "Rate") { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.didTapRate(for: self.serviceId)
                }
            ])

        default:
            cellContextMenu.menu = UIMenu(children: [
                UIAction(title: "See Details") { [weak self] _ in
                    guard let self else { return }
                    self.delegate?.didTapSeeDetails(for: self.serviceId)
                }
            ])
        }

        cellContextMenu.showsMenuAsPrimaryAction = true
        cellContextMenu.changesSelectionAsPrimaryAction = false
    }


    @IBAction func approveBtnTap(_ sender: UIButton) {
        delegate?.didTapApprove(for: serviceId)
    }
    
    @IBAction func declineBtnTap(_ sender: UIButton) {
        delegate?.didTapDecline(for: serviceId)
    }
}
