//
//  BookingPageController.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class BookingPageController: BaseViewController {
    @IBOutlet weak var locationTextField: UITextField!
    var service: Service?
    private var pickedDate: Date = Date.now
    private var pickedHour: Int = 8
    private var pickedMinute: Int = 0
    private let bookingManager = BookingManager()
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        pickedDate = sender.date
    }
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        pickedHour = calendar.component(.hour, from: sender.date)
        pickedMinute = calendar.component(.minute, from: sender.date)
    }
    
    
    @IBAction func continueToPament(_ sender: UIButton) {
        if Date.now >= pickedDate {
            showAlert(message: "Must pick a future date")
            return
        }
        
        if locationTextField.text?.isEmpty ?? true {
            showAlert(message: "Please enter a location")
            return
        }
        
        let sb = UIStoryboard(name: "payment", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "PaymentMethodViewController" ) as! PaymentMethodViewController
        vc.serviceID = service?.id
        vc.price = service?.priceBD
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        bookingManager.saveBooking(Booking(serviceId: service!.id!, userId: LoginPageController.loggedinUser!.id!, providerId: service!.providerId, totalPrice: service!.priceBD, location: locationTextField.text!, date: pickedDate, time: formatTime(hours: pickedHour, minutes: pickedMinute))) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            self?.showAlert(message: "Service booked successfully!", title: "Success")
        }
        
    }
    
    @IBAction func cancelBooking(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func showAlert(message: String, title: String = "Validation Error") {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func formatTime(hours: Int, minutes: Int) -> String {
        // Validate input
        guard hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 else {
            return "Invalid time"
        }
        
        // Convert to 12-hour format
        let hour12: Int
        let period: String
        
        if hours == 0 {
            hour12 = 12
            period = "AM"
        } else if hours == 12 {
            hour12 = 12
            period = "PM"
        } else if hours > 12 {
            hour12 = hours - 12
            period = "PM"
        } else {
            hour12 = hours
            period = "AM"
        }
        
        // Format minutes with leading zero
        let formattedMinutes = String(format: "%02d", minutes)
        
        return "\(hour12):\(formattedMinutes) \(period)"
    }

}
