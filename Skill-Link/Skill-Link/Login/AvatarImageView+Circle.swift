//
//  AvatarImageView+Circle.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 01/01/2026.
//

import Foundation
import UIKit

extension UIImageView {

    // Makes the image view look like a circle avatar without cutting the image.
    
    func applyCircleAvatarNoCrop(background: UIColor = .systemGray6) {
        clipsToBounds = true
        layer.masksToBounds = true
        contentMode = .scaleAspectFit
        backgroundColor = background
    }

   
    func updateCircleMask() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
