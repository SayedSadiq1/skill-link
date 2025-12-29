//
//  AvailabilityViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class AvailabilityViewController: BaseViewController {

    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // If already chosen before, show it
        if let date = filters.availabilityDate {
            datePicker.date = date
        }
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        filters.availabilityDate = datePicker.date
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    
}
