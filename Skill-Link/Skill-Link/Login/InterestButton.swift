//
//  InterestButton.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 25/12/2025.
//

import UIKit

class InterestButton: UIButton {

    private var tapped = false
    
    func toggle() {
        self.layer.cornerRadius = 8
        if !tapped {
            self.layer.borderColor = UIColor.systemBlue.cgColor
            self.layer.borderWidth = 1
        } else {
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
        }
        tapped = !tapped
    }

}
