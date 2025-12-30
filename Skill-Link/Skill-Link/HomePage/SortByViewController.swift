//
//  SortByViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class SortByViewController: BaseViewController {

    // MARK: - Data
    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    // MARK: - Outlets
    @IBOutlet weak var priceLowHighSwitch: UISwitch!
    @IBOutlet weak var priceHighLowSwitch: UISwitch!
    @IBOutlet weak var ratingHighLowSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        syncFromFilters()
    }

    // Price radio behavior (only one can be ON at a time)
    @IBAction func priceSwitchChanged(_ sender: UISwitch) {
        if sender == priceLowHighSwitch && sender.isOn {
            priceHighLowSwitch.isOn = false
            filters.priceSort = .lowToHigh
        } else if sender == priceHighLowSwitch && sender.isOn {
            priceLowHighSwitch.isOn = false
            filters.priceSort = .highToLow
        }

        // if both OFF => no price sort
        if !priceLowHighSwitch.isOn && !priceHighLowSwitch.isOn {
            filters.priceSort = nil
        }
    }

    // Rating independent (can be ON with price)
    @IBAction func ratingSwitchChanged(_ sender: UISwitch) {
        filters.sortByRating = sender.isOn
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    private func syncFromFilters() {
        priceLowHighSwitch.isOn = (filters.priceSort == .lowToHigh)
        priceHighLowSwitch.isOn = (filters.priceSort == .highToLow)
        ratingHighLowSwitch.isOn = filters.sortByRating
    }
}
