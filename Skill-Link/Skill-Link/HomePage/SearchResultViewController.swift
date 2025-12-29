//
//  SearchResultViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class SearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    // This stores what the user last applied
    var currentFilters = SearchFilters()

    // Demo data
    private let services: [Service] = [
        Service(id: UUID(), title: "Professional Plumbing Service", description: "Fix leaks", category: "Plumbing",
                priceBD: 70, priceType: .fixed, rating: 5.0,
                provider: UserProfile(name: "Ali Yusuf", skills: [""], brief: "", contact: ""), available: true, disclaimers: []),

        Service(id: UUID(), title: "Electrician Home Wiring", description: "Wiring & repair", category: "Electrician",
                priceBD: 50, priceType: .hourly, rating: 4.6,
                provider: UserProfile(name: "Ahmed Raza", skills: [""], brief: "", contact: ""), available: true, disclaimers: []),

        Service(id: UUID(), title: "Deep Cleaning Service", description: "Home cleaning", category: "Landscaping",
                priceBD: 40, priceType: .fixed, rating: 4.8,
                provider: UserProfile(name: "Sara Ali", skills: [""], brief: "", contact: ""), available: false, disclaimers: [])
    ]

    private var filteredServices: [Service] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160

        applyFiltersAndReload()
    }

    // MARK: - Filters apply
    private func applyFiltersAndReload() {
        var result = services

        // Category filter
        if !currentFilters.selectedCategories.isEmpty {
            result = result.filter { currentFilters.selectedCategories.contains($0.category) }
        }

        // Availability filter (simple: if user set availabilityDate, show only available == true)
        if currentFilters.availabilityDate != nil {
            result = result.filter { $0.available == true }
        }

        // Price sorting
        if let priceSort = currentFilters.priceSort {
            switch priceSort {
            case .lowToHigh:
                result.sort { $0.priceBD < $1.priceBD }
            case .highToLow:
                result.sort { $0.priceBD > $1.priceBD }
            }
        }

        // Rating sorting (independent, can be ON with price)
        if currentFilters.sortByRating {
            result.sort { $0.rating > $1.rating }
        }

        filteredServices = result
        tableView.reloadData()
    }

    // MARK: - Segue to Filters
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilters" {
            guard let vc = segue.destination as? FiltersViewController else { return }

            vc.filters = currentFilters

            vc.onApply = { [weak self] newFilters in
                guard let self = self else { return }
                self.currentFilters = newFilters
                self.applyFiltersAndReload()
            }
        }
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCellTableViewCell

        let service = filteredServices[indexPath.row]
        cell.serviceNameLabel.text = service.title
        cell.priceLabel.text = "\(Int(service.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", service.rating)

        return cell
    }
}
