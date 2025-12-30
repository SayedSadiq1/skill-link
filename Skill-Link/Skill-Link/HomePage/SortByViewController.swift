//
//  SortByViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class SortByViewController: BaseViewController {

    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    @IBOutlet weak var priceHighToLowSwitch: UISwitch?
    @IBOutlet weak var priceLowToHighSwitch: UISwitch?
    @IBOutlet weak var ratingHighToLowSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        syncUI()
    }

    private func syncUI() {
        priceHighToLowSwitch?.isOn = (filters.priceSort == .highToLow)
        priceLowToHighSwitch?.isOn = (filters.priceSort == .lowToHigh)
        ratingHighToLowSwitch?.isOn = filters.sortByRating
    }

    @IBAction func priceHighToLowChanged(_ sender: UISwitch) {
        if sender.isOn {
            priceLowToHighSwitch?.setOn(false, animated: true)
        }
    }

    @IBAction func priceLowToHighChanged(_ sender: UISwitch) {
        if sender.isOn {
            priceHighToLowSwitch?.setOn(false, animated: true)
        }
    }

    @IBAction func ratingHighToLowChanged(_ sender: UISwitch) {
        // no extra logic needed
    }

    // ✅ IMPORTANT: We compute the filter values here from actual switch states
    @IBAction func applyTapped(_ sender: UIButton) {

        let highToLow = priceHighToLowSwitch?.isOn ?? false
        let lowToHigh = priceLowToHighSwitch?.isOn ?? false
        let ratingHighToLow = ratingHighToLowSwitch?.isOn ?? false

        // price sort
        if highToLow {
            filters.priceSort = .highToLow
        } else if lowToHigh {
            filters.priceSort = .lowToHigh
        } else {
            filters.priceSort = nil
        }

        // rating sort
        filters.sortByRating = ratingHighToLow

        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }
}
