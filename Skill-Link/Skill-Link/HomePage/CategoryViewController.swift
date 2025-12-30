//
//  CategoryViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class CategoryViewController: BaseViewController {

    // MARK: - Data
    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    // MARK: - Outlets
    @IBOutlet weak var plumbingSwitch: UISwitch!
    @IBOutlet weak var electricianSwitch: UISwitch!
    @IBOutlet weak var landscapingSwitch: UISwitch!
    @IBOutlet weak var tutoringSwitch: UISwitch!
    @IBOutlet weak var uiuxSwitch: UISwitch!
    @IBOutlet weak var codingSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
       syncSwitchesFromFilters()
    }

    // MARK: - Switch changed
    @IBAction func categorySwitchChanged(_ sender: UISwitch) {
        filters.selectedCategories = currentSelectedCategories()
    }

    // MARK: - Apply
    @IBAction func applyTapped(_ sender: UIButton) {
        filters.selectedCategories = currentSelectedCategories()
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    private func syncSwitchesFromFilters() {
        let selected = Set(filters.selectedCategories)
        plumbingSwitch.isOn = selected.contains("Plumbing")
        electricianSwitch.isOn = selected.contains("Electrician")
        landscapingSwitch.isOn = selected.contains("Landscaping")
        tutoringSwitch.isOn = selected.contains("Tutoring")
        uiuxSwitch.isOn = selected.contains("UI/UX Design")
        codingSwitch.isOn = selected.contains("Coding")
    }

    private func currentSelectedCategories() -> [String] {
        var result: [String] = []
        if plumbingSwitch.isOn { result.append("Plumbing") }
        if electricianSwitch.isOn { result.append("Electrician") }
        if landscapingSwitch.isOn { result.append("Landscaping") }
        if tutoringSwitch.isOn { result.append("Tutoring") }
        if uiuxSwitch.isOn { result.append("UI/UX Design") }
        if codingSwitch.isOn { result.append("Coding") }
        return result
    }
}
