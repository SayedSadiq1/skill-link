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
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
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
        
        leadingConstraint.isActive = !isSender
        trailingConstraint.isActive = isSender
        
        bubbleView.backgroundColor = isSender ? .systemBlue : .systemGray5
        messageLabel.textColor = isSender ? .white : .black
        
        if isSender {
            bubbleView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
        } else {
            bubbleView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        
        layoutIfNeeded()
    }
}
