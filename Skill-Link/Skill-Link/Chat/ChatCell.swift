//
//  ChatCell.swift
//  Skill-Link
//
//  Created by sayed sadiq on 28/12/2025.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.numberOfLines = 0
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
    }
    

    
    func configure(message: String, isSender: Bool) {
        messageLabel.text = message

        if isSender {
            leadingConstraint?.priority = .defaultLow
            trailingConstraint?.priority = .required
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white

            bubbleView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
        } else {
            leadingConstraint?.priority = .required
            trailingConstraint?.priority = .defaultLow
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .black

            bubbleView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        }

        contentView.layoutIfNeeded()
    }

}
