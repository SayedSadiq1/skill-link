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

    @IBOutlet weak var datePicker: UIDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let date = filters.availabilityDate {
            datePicker?.date = date
        }
    }

    @IBAction func applyTapped(_ sender: UIButton) {
        let selected = datePicker?.date ?? Date()

        // ✅ If time is 12am–8am -> show alert and do NOT apply
        if isBlockedTime(selected) {
            showNoServiceAlert()
            return
        }

        filters.availabilityDate = selected
        filters.availabilitySlot = timeSlot(from: selected)

        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    private func isBlockedTime(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 0 && hour < 8  // 12:00 AM (0) to 7:59 AM
    }

    private func timeSlot(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 8..<12:   return "Morning (8–12)"
        case 12..<16:  return "Afternoon (12–4)"
        case 16..<20:  return "Evening (4–8)"
        default:       return "Night (8–12)" // 8pm–12am
        }
    }

    private func showNoServiceAlert() {
        let alert = UIAlertController(
            title: "No Service Available",
            message: "No service is available between 12:00 AM and 8:00 AM. Please choose another time.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
