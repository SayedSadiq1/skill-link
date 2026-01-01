//
//  SearchResultViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class SearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var currentFilters = SearchFilters()

    // MARK: - Chips UI
    private let chipsHeight: CGFloat = 56
    private let chipsContainer = UIView()
    private let chipsScrollView = UIScrollView()
    private let chipsStackView = UIStackView()

    // MARK: - Demo Data (replace with Firebase later)
    private let services: [Service] = [
        Service(id: UUID(), title: "Professional Plumbing Service", description: "",
                category: "Plumbing", priceBD: 70, priceType: .Fixed, rating: 5.0,
                provider: UserProfile(name: "Ali", skills: [], brief: "", contact: ""),
                available: true, disclaimers: [], durationMinHours: 1, durationMaxHours: 2, availableAt: "Morning (8–12)"),

        Service(id: UUID(), title: "Electrician Home Wiring", description: "",
                category: "Electrician", priceBD: 50, priceType: .Hourly, rating: 4.6,
                provider: UserProfile(name: "Ahmed", skills: [], brief: "", contact: ""),
                available: true, disclaimers: [], durationMinHours: 1, durationMaxHours: 2, availableAt: "Afternoon (12–4)"),

        Service(id: UUID(), title: "Landscaping Garden Care", description: "",
                category: "Landscaping", priceBD: 30, priceType: .Hourly, rating: 4.4,
                provider: UserProfile(name: "Salman", skills: [], brief: "", contact: ""),
                available: false, disclaimers: [], durationMinHours: 1, durationMaxHours: 2, availableAt: "Evening (4–8)")
    ]

    private var filteredServices: [Service] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160
        tableView.isScrollEnabled = true

        setupChipsBar()

        filteredServices = services
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        currentFilters = FiltersStore.load()
        rebuildChips()
        applyFilters()
    }

    // MARK: - Chips Bar (placed directly under blue header in WHITE area)
    private func setupChipsBar() {
        chipsContainer.translatesAutoresizingMaskIntoConstraints = false
        chipsScrollView.translatesAutoresizingMaskIntoConstraints = false
        chipsStackView.translatesAutoresizingMaskIntoConstraints = false

        chipsContainer.backgroundColor = .clear

        chipsScrollView.showsHorizontalScrollIndicator = false
        chipsScrollView.alwaysBounceHorizontal = true
        chipsScrollView.alwaysBounceVertical = false
        chipsScrollView.isDirectionalLockEnabled = true

        chipsStackView.axis = .horizontal
        chipsStackView.spacing = 12
        chipsStackView.alignment = .center
        chipsStackView.distribution = .fill

        view.addSubview(chipsContainer)
        chipsContainer.addSubview(chipsScrollView)
        chipsScrollView.addSubview(chipsStackView)

        NSLayoutConstraint.activate([
            // ✅ Anchor chips relative to the table top so it sits in WHITE area (not in blue header)
            chipsContainer.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -chipsHeight - 8),
            chipsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsContainer.heightAnchor.constraint(equalToConstant: chipsHeight),

            chipsScrollView.leadingAnchor.constraint(equalTo: chipsContainer.leadingAnchor, constant: 16),
            chipsScrollView.trailingAnchor.constraint(equalTo: chipsContainer.trailingAnchor, constant: -16),
            chipsScrollView.topAnchor.constraint(equalTo: chipsContainer.topAnchor),
            chipsScrollView.bottomAnchor.constraint(equalTo: chipsContainer.bottomAnchor),

            chipsStackView.leadingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.leadingAnchor),
            chipsStackView.trailingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.trailingAnchor),
            chipsStackView.topAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.topAnchor),
            chipsStackView.bottomAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.bottomAnchor),
            chipsStackView.heightAnchor.constraint(equalTo: chipsScrollView.frameLayoutGuide.heightAnchor)
        ])

        // ✅ Push table content down so first cell never overlaps chips
        tableView.contentInset.top = chipsHeight + 16
        tableView.scrollIndicatorInsets.top = chipsHeight + 16
    }

    private func rebuildChips() {
        chipsStackView.arrangedSubviews.forEach {
            chipsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let titles = chipTitles()
        chipsContainer.isHidden = titles.isEmpty
        guard !titles.isEmpty else { return }

        for t in titles {
            chipsStackView.addArrangedSubview(makeChip(text: t))
        }

        view.layoutIfNeeded()
    }

    private func chipTitles() -> [String] {
        var arr: [String] = []

        // categories (each as its own chip)
        if !currentFilters.selectedCategories.isEmpty {
            arr.append(contentsOf: currentFilters.selectedCategories)
        }

        // sort
        if let ps = currentFilters.priceSort {
            arr.append(ps == .lowToHigh ? "Price Low > High" : "Price High > Low")
        }
        if currentFilters.sortByRating {
            arr.append("Rating High > Low")
        }

        // availability
        if let slot = currentFilters.availabilitySlot, !slot.isEmpty {
            arr.append(slot)
        }

        return arr
    }

    private func makeChip(text: String) -> UILabel {
        let lbl = PaddingLabel()
        lbl.text = text
        lbl.padding = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .black
        lbl.backgroundColor = .white
        lbl.layer.cornerRadius = 18
        lbl.layer.borderWidth = 1
        lbl.layer.borderColor = UIColor.systemGray4.cgColor
        lbl.clipsToBounds = true
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byClipping
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }

    // MARK: - Filtering
    private func applyFilters() {
        var result = services

        // Category filter
        if !currentFilters.selectedCategories.isEmpty {
            result = result.filter { currentFilters.selectedCategories.contains($0.category) }
        }

        // ✅ Availability filter (NEW)
        // Your AvailabilityViewController stores "Morning (8–12)" etc.
        if let slot = currentFilters.availabilitySlot,
           !slot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            let wanted = normalizeSlot(slot)

            result = result.filter { service in
                // If seeker chose a slot: only show available services matching that slot
                guard service.available else { return false }
                return normalizeSlot(service.availableAt) == wanted
            }
        }

        // Sort by price
        if let ps = currentFilters.priceSort {
            switch ps {
            case .lowToHigh: result.sort { $0.priceBD < $1.priceBD }
            case .highToLow: result.sort { $0.priceBD > $1.priceBD }
            }
        }

        // Sort by rating
        if currentFilters.sortByRating {
            result.sort { $0.rating > $1.rating }
        }

        filteredServices = result
        tableView.reloadData()
    }

    // ✅ Normalize "Night (8–12)" and "Night" to same key
    private func normalizeSlot(_ s: String) -> String {
        let lower = s.lowercased()
        if lower.contains("morning") { return "morning" }
        if lower.contains("afternoon") { return "afternoon" }
        if lower.contains("evening") { return "evening" }
        if lower.contains("night") { return "night" }
        return lower.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredServices.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCellTableViewCell
        let s = filteredServices[indexPath.row]

        cell.serviceNameLabel.text = s.title
        cell.priceLabel.text = "\(Int(s.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", s.rating)

        // ✅ IMPORTANT: always set BOTH states because cells are reused
        if s.available {
            cell.availabilityLabel.text = "Available \(s.availableAt)"
            cell.availabilityLabel.textColor = .systemGreen

            cell.checkmarkImage.image = UIImage(systemName: "checkmark.circle.fill")
            cell.checkmarkImage.tintColor = .systemGreen
        } else {
            cell.availabilityLabel.text = "Unavailable"
            cell.availabilityLabel.textColor = .systemRed

            cell.checkmarkImage.image = UIImage(systemName: "xmark.circle.fill")
            cell.checkmarkImage.tintColor = .systemRed
        }

        return cell
    }
}

// MARK: - PaddingLabel
final class PaddingLabel: UILabel {
    var padding = UIEdgeInsets.zero
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + padding.left + padding.right,
                      height: s.height + padding.top + padding.bottom)
    }
}

