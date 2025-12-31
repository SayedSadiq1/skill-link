//
//  BookingPageController.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class BookingPageController: BaseViewController {
    @IBOutlet weak var locationTextField: UITextField!
    var pickedDate: Date = Date.now
    var pickedHour: Int = 8
    var pickedMinute: Int = 0
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        pickedDate = sender.date
    }
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sender.date)
        let minute = calendar.component(.minute, from: sender.date)
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
    }
    @IBAction func cancelBooking(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
