//
//  AvatarImageView+Circle.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 01/01/2026.
//

import Foundation
import UIKit

extension UIImageView {

    /// Fully visible circular avatar (no cropping)
    func applyCircleAvatarNoCrop(background: UIColor = .systemGray6) {
        clipsToBounds = true
        layer.masksToBounds = true
        contentMode = .scaleAspectFit   // ✅ prevents cropping
        backgroundColor = background
    }

    /// Call in viewDidLayoutSubviews
    func updateCircleMask() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
