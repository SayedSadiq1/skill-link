//
//  FiltersViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class FiltersViewController: BaseViewController {

    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?
    var onReset: (() -> Void)?

    @IBOutlet weak var categoryValueLabel: UILabel?
    @IBOutlet weak var sortValueLabel: UILabel?
    @IBOutlet weak var availabilityValueLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load saved filters (if any)
        filters = FiltersStore.load()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ Always refresh (in case child screen changed something)
        filters = FiltersStore.load()
        updateUI()
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        // ✅ Always persist here
        FiltersStore.save(filters)

        // Notify parent if it wants
        onApply?(filters)

        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetTapped(_ sender: UIButton) {
        filters = SearchFilters()
        FiltersStore.clear()
        updateUI()
        onReset?()
    }

    private func updateUI() {
        categoryValueLabel?.text = filters.selectedCategories.isEmpty
        ? "Any"
        : filters.selectedCategories.joined(separator: ", ")

        var sortParts: [String] = []
        if let ps = filters.priceSort {
            sortParts.append(ps == .lowToHigh ? "Price Low > High" : "Price High > Low")
        }
        if filters.sortByRating {
            sortParts.append("Rating High > Low")
        }
        sortValueLabel?.text = sortParts.isEmpty ? "None" : sortParts.joined(separator: " + ")

        availabilityValueLabel?.text = filters.availabilitySlot ?? "Any"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toCategory",
           let vc = segue.destination as? CategoryViewController {
            vc.filters = filters
            vc.onApply = { updated in
                FiltersStore.save(updated)   // ✅ persist immediately
            }
        }

        if segue.identifier == "toSortBy",
           let vc = segue.destination as? SortByViewController {
            vc.filters = filters
            vc.onApply = { updated in
                FiltersStore.save(updated)   // ✅ persist immediately
            }
        }

        if segue.identifier == "toAvailability",
           let vc = segue.destination as? AvailabilityViewController {
            vc.filters = filters
            vc.onApply = { updated in
                FiltersStore.save(updated)   // ✅ persist immediately
            }
        }
    }
}
