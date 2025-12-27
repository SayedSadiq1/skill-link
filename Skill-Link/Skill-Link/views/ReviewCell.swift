//
//  ReviewCell.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//
import UIKit

class ReviewCell : UITableViewCell{
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsContainer: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with review: Review) {
        nameLabel.text = review.name
        messageLabel.text = review.message
        configureStars(rating: review.rating)
    }
    
    func configureStars(rating: Int) {
        starsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 1...5 {
            let imageName = i <= rating ? "starfill" : "star"
            let starImageView = UIImageView(image: UIImage(named: imageName))
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starsContainer.addArrangedSubview(starImageView)
        }
    }
}

