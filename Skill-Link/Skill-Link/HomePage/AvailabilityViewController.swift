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
        let selected = datePicker.date
        filters.availabilityDate = selected
        filters.availabilitySlot = timeSlot(from: selected)

        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Time -> Slot mapping
    private func timeSlot(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        // 8-12 Morning, 12-4 Afternoon, 4-8 Evening, else Night
        switch hour {
        case 8..<12:
            return "Morning (8–12)"
        case 12..<16:
            return "Afternoon (12–4)"
        case 16..<20:
            return "Evening (4–8)"
        default:
            return "Night (8–12)"
        }
    }
}

