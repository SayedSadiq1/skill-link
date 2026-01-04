//
//  RoundedButton.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 04/01/2026.
//

import UIKit

@IBDesignable
final class RoundedButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 12
    @IBInspectable var contentHPadding: CGFloat = 16
    @IBInspectable var contentVPadding: CGFloat = 12

    override func awakeFromNib() {
        super.awakeFromNib()
        apply()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        apply()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }

    private func apply() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        // Keep whatever colors you set in storyboard
        contentEdgeInsets = UIEdgeInsets(
            top: contentVPadding,
            left: contentHPadding,
            bottom: contentVPadding,
            right: contentHPadding
        )

        // Make text consistent, but not required
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
}

