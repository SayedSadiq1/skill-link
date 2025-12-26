//
//  CardLabel.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 21/12/2025.
//

import UIKit

class CardLabel: UILabel {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 7))
        layer.mask?.borderWidth = 3
        layer.backgroundColor = UIColor.tintColor.cgColor
        layer.borderColor = UIColor.black.cgColor
        super.draw(rect)
    }
    

}
