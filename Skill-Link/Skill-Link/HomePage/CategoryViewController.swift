//
//  CategoryViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class CategoryViewController: BaseViewController {

    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    private let categories = ["Plumbing", "Electrician", "Landscaping", "Tutoring", "UI/UX Design", "Coding"]

    @IBOutlet var categorySwitches: [UISwitch]?

    override func viewDidLoad() {
        super.viewDidLoad()
        syncUI()
    }

    private func syncUI() {
        guard let switches = categorySwitches else { return }

        // sort by tag so mapping is stable
        let sorted = switches.sorted { $0.tag < $1.tag }

        for sw in sorted {
            let idx = sw.tag
            guard idx >= 0, idx < categories.count else { continue }
            let cat = categories[idx]
            sw.isOn = filters.selectedCategories.contains(cat)
        }
    }

    @IBAction func categorySwitchChanged(_ sender: UISwitch) {
        let idx = sender.tag
        guard idx >= 0, idx < categories.count else { return }
        let cat = categories[idx]

        if sender.isOn {
            if !filters.selectedCategories.contains(cat) {
                filters.selectedCategories.append(cat)
            }
        } else {
            filters.selectedCategories.removeAll { $0 == cat }
        }
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }
}
