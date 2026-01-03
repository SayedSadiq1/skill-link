//
//  MyServiceCell.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 02/01/2026.
//
import UIKit

final class MyServiceCell: UITableViewCell {

    var onViewDetails: (() -> Void)?

    private let card = UIView()
    private let statusPill = UILabel()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let availabilityLabel = UILabel()
    private let viewDetailsButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 13, weight: .semibold)
        statusPill.textAlignment = .center
        statusPill.layer.cornerRadius = 10
        statusPill.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 2

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = .systemFont(ofSize: 14)
        categoryLabel.textColor = .secondaryLabel

        availabilityLabel.translatesAutoresizingMaskIntoConstraints = false
        availabilityLabel.font = .systemFont(ofSize: 14)
        availabilityLabel.textColor = .secondaryLabel

        viewDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        viewDetailsButton.setTitle("View Details", for: .normal)
        viewDetailsButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        viewDetailsButton.setTitleColor(.white, for: .normal)
        viewDetailsButton.backgroundColor = UIColor(red: 0.07, green: 0.15, blue: 0.33, alpha: 1.0)
        viewDetailsButton.layer.cornerRadius = 10
        viewDetailsButton.clipsToBounds = true
        viewDetailsButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        viewDetailsButton.addTarget(self, action: #selector(viewDetailsTapped), for: .touchUpInside)

        let topRow = UIStackView(arrangedSubviews: [UIView(), statusPill])
        topRow.axis = .horizontal
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let metaStack = UIStackView(arrangedSubviews: [categoryLabel, availabilityLabel])
        metaStack.axis = .vertical
        metaStack.spacing = 4
        metaStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(topRow)
        card.addSubview(titleLabel)
        card.addSubview(metaStack)
        card.addSubview(viewDetailsButton)

        NSLayoutConstraint.activate([
            topRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            topRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            topRow.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            statusPill.heightAnchor.constraint(equalToConstant: 28),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 10),

            metaStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            metaStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            metaStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            viewDetailsButton.topAnchor.constraint(equalTo: metaStack.bottomAnchor, constant: 12),
            viewDetailsButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            viewDetailsButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(title: String, category: String, availableAt: String, available: Bool) {
        titleLabel.text = title
        categoryLabel.text = category
        availabilityLabel.text = availableAt

        if available {
            statusPill.text = "Active"
            statusPill.textColor = .systemGreen
            statusPill.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            statusPill.text = "Disabled"
            statusPill.textColor = .systemRed
            statusPill.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }
    }

    @objc private func viewDetailsTapped() {
        onViewDetails?()
    }
}
