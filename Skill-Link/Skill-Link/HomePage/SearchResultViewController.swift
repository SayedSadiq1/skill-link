//
//  SearchResultViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//





/// SearchResultViewController.swift
// Skill-Link
//
// FIX: Chips sometimes empty because currentFilters may be set AFTER viewDidLoad,
// or view is shown again and chips aren’t rebuilt.
// Solution:
// 1) Rebuild chips in viewWillAppear (always)
// 2) Rebuild chips when currentFilters is updated (didSet)
// 3) Hide stack content if no filters (empty)
//
// Storyboard:
// - Your horizontal UIStackView must be connected to chipsStackView outlet
// - Keep stack view height constraint (optional), but it can be 0 if no chips

import UIKit

final class SearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chipsStackView: UIStackView!

    // If SearchService sets this before push, didSet might run before outlets exist,
    // so we refresh again in viewWillAppear.
    var currentFilters = SearchFilters() {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }

    // Notify SearchServices that filters changed (chip removed)
    var onFiltersChanged: ((SearchFilters) -> Void)?

    // Demo data (replace later with Firebase)
    private let services: [Service] = [
//        Service(id: UUID(),
//                title: "Professional Plumbing Service",
//                description: "Fix leaks",
//                category: "Plumbing",
//                priceBD: 70,
//                priceType: .fixed,
//                rating: 5.0,
//                provider: UserProfile(name: "Ali Yusuf", skills: [""], brief: "", contact: ""),
//                available: true,
//                disclaimers: []),
//
//        Service(id: UUID(),
//                title: "Electrician Home Wiring",
//                description: "Wiring & repair",
//                category: "Electrician",
//                priceBD: 50,
//                priceType: .hourly,
//                rating: 4.6,
//                provider: UserProfile(name: "Ahmed Raza", skills: [""], brief: "", contact: ""),
//                available: true,
//                disclaimers: []),
//
//        Service(id: UUID(),
//                title: "Deep Cleaning Service",
//                description: "Home cleaning",
//                category: "Landscaping",
//                priceBD: 40,
//                priceType: .fixed,
//                rating: 4.8,
//                provider: UserProfile(name: "Sara Ali", skills: [""], brief: "", contact: ""),
//                available: false,
//                disclaimers: [])
    ]

    private var visibleServices: [Service] = []

    private enum ChipType { case category, sort, availability }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160

        chipsStackView.axis = .horizontal
        chipsStackView.alignment = .fill
        chipsStackView.distribution = .fillProportionally
        chipsStackView.spacing = 10

        refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ Always rebuild when screen appears (fix for “chips empty after search”)
        refreshUI()
    }

    private func refreshUI() {
        buildChips()
        applyFiltersAndReload()
    }

    // MARK: - Chips (StackView)

    private func buildChips() {
        // Clear old chips
        for v in chipsStackView.arrangedSubviews {
            chipsStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        var chipItems: [(ChipType, String)] = []

        // Category chip
        if !currentFilters.selectedCategories.isEmpty {
            if currentFilters.selectedCategories.count == 1 {
                chipItems.append((.category, currentFilters.selectedCategories[0]))
            } else {
                chipItems.append((.category, "\(currentFilters.selectedCategories[0]) +\(currentFilters.selectedCategories.count - 1)"))
            }
        }

        // Sort chip
        var sortParts: [String] = []
        if let ps = currentFilters.priceSort {
            sortParts.append(ps == .lowToHigh ? "Price Low > High" : "Price High > Low")
        }
        if currentFilters.sortByRating {
            sortParts.append("Rating High > Low")
        }
        if !sortParts.isEmpty {
            chipItems.append((.sort, sortParts.joined(separator: " + ")))
        }

        // Availability chip
        if let slot = currentFilters.availabilitySlot, !slot.isEmpty {
            // nicer short display
            let short = slot
                .replacingOccurrences(of: " (8–12)", with: "")
                .replacingOccurrences(of: " (12–4)", with: "")
                .replacingOccurrences(of: " (4–8)", with: "")
            chipItems.append((.availability, short))
        }

        // ✅ If no filters => keep stack view empty
        if chipItems.isEmpty {
            chipsStackView.isHidden = true
            return
        } else {
            chipsStackView.isHidden = false
        }

        for item in chipItems {
            let btn = makeChipButton(title: item.1)

            switch item.0 {
            case .category: btn.tag = 1
            case .sort: btn.tag = 2
            case .availability: btn.tag = 3
            }

            btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            chipsStackView.addArrangedSubview(btn)
        }
    }

    private func makeChipButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("✕  \(title)", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor.systemGray5
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.titleLabel?.lineBreakMode = .byTruncatingTail
        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        // 1=category, 2=sort, 3=availability
        if sender.tag == 1 {
            currentFilters.selectedCategories = []
        } else if sender.tag == 2 {
            currentFilters.priceSort = nil
            currentFilters.sortByRating = false
        } else if sender.tag == 3 {
            currentFilters.availabilitySlot = nil
            currentFilters.availabilityDate = nil
        }

        onFiltersChanged?(currentFilters)
        refreshUI()
    }

    // MARK: - Filtering / Sorting

    private func applyFiltersAndReload() {
        let hasAny =
            !currentFilters.selectedCategories.isEmpty ||
            currentFilters.priceSort != nil ||
            currentFilters.sortByRating == true ||
            (currentFilters.availabilitySlot != nil && !(currentFilters.availabilitySlot ?? "").isEmpty)

        // No filters => random order
        if !hasAny {
            visibleServices = services.shuffled()
            tableView.reloadData()
            return
        }

        var result = services

        // Category filter
        if !currentFilters.selectedCategories.isEmpty {
            result = result.filter { currentFilters.selectedCategories.contains($0.category) }
        }

        // Availability filter (slot chosen) – demo behavior until services store real slot
        if let slot = currentFilters.availabilitySlot, !slot.isEmpty {
            _ = slot
            result = result.filter { $0.available == true }
        }

        // Price sort
        if let ps = currentFilters.priceSort {
            switch ps {
            case .lowToHigh:
                result.sort { $0.priceBD < $1.priceBD }
            case .highToLow:
                result.sort { $0.priceBD > $1.priceBD }
            }
        }

        // Rating sort
        if currentFilters.sortByRating {
            result.sort { $0.rating > $1.rating }
        }

        visibleServices = result
        tableView.reloadData()
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCellTableViewCell

        let service = visibleServices[indexPath.row]
        cell.serviceNameLabel.text = service.title
        cell.priceLabel.text = "\(Int(service.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", service.rating)

        return cell
    }
}

