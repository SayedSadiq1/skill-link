//
//  ServiceDetailsHeaderCell.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class ServiceDetailsHeaderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var categoryLabel: CardLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var star1Img: UIImageView!
    @IBOutlet weak var star2Img: UIImageView!
    @IBOutlet weak var star3Img: UIImageView!
    @IBOutlet weak var star4Img: UIImageView!
    @IBOutlet weak var star5Img: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        categoryLabel.setBackgroundColor(UIColor.tintColor)
        categoryLabel.alpha = 0.65
    }

    
    func setStarsPrecise(rating: Double) {
        let clampedRating = min(max(rating, 0), 5)
        let stars = [star1Img, star2Img, star3Img, star4Img, star5Img]
        
        for (index, starImageView) in stars.enumerated() {
            let starPosition = Double(index + 1)
            
            if starPosition <= clampedRating {
                // Full star
                starImageView?.image = UIImage(systemName: "star.fill")
                starImageView?.tintColor = UIColor.systemYellow
            } else if starPosition - 1 < clampedRating {
                // Partial star (calculate fill percentage)
                let fillPercentage = clampedRating - Double(index)
                let starFill = round(fillPercentage * 100) / 100 // Round to 2 decimals
                
                if starFill >= 0.75 {
                    starImageView?.image = UIImage(systemName: "star.fill")
                } else if starFill >= 0.25 {
                    starImageView?.image = UIImage(systemName: "star.leadinghalf.filled")
                } else {
                    starImageView?.image = UIImage(systemName: "star")
                }
                starImageView?.tintColor = UIColor.systemYellow
            } else {
                // Empty star
                starImageView?.image = UIImage(systemName: "star")
                starImageView?.tintColor = UIColor.lightGray
            }
        }
        
        reviewsLabel.text = String(format: "%.1f", clampedRating)
    }
}
