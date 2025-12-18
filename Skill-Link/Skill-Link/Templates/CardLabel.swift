//
//  CardLabel.swift
//  Skill-Link
//
//  Created by BP-36-212-19 on 18/12/2025.
//

import UIKit

class CardLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
       @IBInspectable var bottomInset: CGFloat = 5.0
       @IBInspectable var leftInset: CGFloat = 7.0
       @IBInspectable var rightInset: CGFloat = 7.0

       override func drawText(in rect: CGRect) {
          let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
           super.drawText(in: rect.inset(by: insets))
       }

       override var intrinsicContentSize: CGSize {
          get {
             var contentSize = super.intrinsicContentSize
             contentSize.height += topInset + bottomInset
             contentSize.width += leftInset + rightInset
             return contentSize
          }
       }
}
