//
//  FiltersViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//


import UIKit

final class FiltersViewController: BaseViewController {

    // MARK: - Data
    var filters = SearchFilters()

    // Called when user taps Apply in Filters screen
    var onApply: ((SearchFilters) -> Void)?

    // MARK: - Outlets
    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var sortValueLabel: UILabel!
    @IBOutlet weak var availabilityValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    // MARK: - Actions
    @IBAction func applyTapped(_ sender: UIButton) {
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetTapped(_ sender: UIButton) {
        filters = SearchFilters()
        updateUI()
    }

    // MARK: - UI
    private func updateUI() {
        // Category
        if filters.selectedCategories.isEmpty {
            categoryValueLabel.text = "Any"
        } else {
            categoryValueLabel.text = filters.selectedCategories.joined(separator: ", ")
        }

        // Sort text (price + rating can be combined)
        var sortParts: [String] = []

        if let price = filters.priceSort {
            switch price {
            case .lowToHigh: sortParts.append("Price: Low → High")
            case .highToLow: sortParts.append("Price: High → Low")
            }
        }

        if filters.sortByRating {
            sortParts.append("Rating: High → Low")
        }

        sortValueLabel.text = sortParts.isEmpty ? "None" : sortParts.joined(separator: " + ")

        // Availability (show slot)
        if let slot = filters.availabilitySlot {
            availabilityValueLabel.text = slot
        } else {
            availabilityValueLabel.text = "Any"
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toCategory",
           let vc = segue.destination as? CategoryViewController {
            vc.filters = filters
            vc.onApply = { [weak self] updated in
                self?.filters = updated
                self?.updateUI()
            }
        }

        if segue.identifier == "toSortBy",
           let vc = segue.destination as? SortByViewController {
            vc.filters = filters
            vc.onApply = { [weak self] updated in
                self?.filters = updated
                self?.updateUI()
            }
        }

        if segue.identifier == "toAvailability",
           let vc = segue.destination as? AvailabilityViewController {
            vc.filters = filters
            vc.onApply = { [weak self] updated in
                self?.filters = updated
                self?.updateUI()
            }
        }
    }
}
