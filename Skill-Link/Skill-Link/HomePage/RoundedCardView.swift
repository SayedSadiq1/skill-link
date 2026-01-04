//
//  RoundedCardView.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 04/01/2026.
//
import UIKit

@IBDesignable
final class RoundedCardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 16
    @IBInspectable var clipToBounds: Bool = true

    // Optional border (leave at 0 if you don’t want it)
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = .clear

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
        clipsToBounds = clipToBounds
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        // NOTE: backgroundColor not touched
    }
}
