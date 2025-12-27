//
//  ReviewsViewController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

import UIKit

class ReviewsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var averageRatingsLabel: UILabel!
    @IBOutlet weak var totalReviewsLabel: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var starsSummaryStackView: UIStackView!

    private let emptyMessageLabel = UILabel()
    private var reviews: [Review] = []
    var serviceID: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupEmptyMessageLabel()

        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        reviewsTableView.rowHeight = UITableView.automaticDimension
        reviewsTableView.estimatedRowHeight = 100

        Task {
                do {
                    try await loadData()
                }
            }
        }

    // MARK: - Empty Message Setup

    private func setupEmptyMessageLabel() {
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.isHidden = true

        view.addSubview(emptyMessageLabel)

        NSLayoutConstraint.activate([
            emptyMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func showEmptyMessage() {
        let text = NSMutableAttributedString()

        text.append(NSAttributedString(
            string: "Sorry...\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.lightGray
            ]
        ))

        text.append(NSAttributedString(
            string: "No reviews yet.",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.lightGray
            ]
        ))

        emptyMessageLabel.attributedText = text
        emptyMessageLabel.alpha = 0
        emptyMessageLabel.isHidden = false

        UIView.animate(withDuration: 0.25) {
            self.emptyMessageLabel.alpha = 1
        }
    }

    // MARK: - Header Update

    private func updateHeader() {
        let total = reviews.count

        totalReviewsLabel.text = "\(total) reviews"

        if total == 0 {
            averageRatingsLabel.text = "0.0"
            configureSummaryStars(average: 0)

            reviewsTableView.isHidden = true
            showEmptyMessage()
            return
        }

        let sum = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(sum) / Double(total)

        averageRatingsLabel.text = String(format: "%.1f", average)
        configureSummaryStars(average: average)

        reviewsTableView.isHidden = false
        emptyMessageLabel.isHidden = true
    }

    // MARK: - Stars Summary

    private func configureSummaryStars(average: Double) {
        starsSummaryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let filledStars = Int(round(average))

        for i in 1...5 {
            let imageName = i <= filledStars ? "starfill" : "star"
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            starsSummaryStackView.addArrangedSubview(imageView)
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as? ReviewCell else {
            return UITableViewCell()
        }

        cell.configure(with: reviews[indexPath.row])
        return cell
    }
    
    func loadData() async throws {
        let fetchedReviews = try await ReviewController.shared.getReviews(serviceID: self.serviceID ?? "")
            
            await MainActor.run {
                self.reviews = fetchedReviews
                self.reviewsTableView.reloadData()
                self.updateHeader()
            }
    }
}
