//
//  ReportController.swift
//  Skill-Link
//
//  Created by BP-36-213-11 on 23/12/2025.
//

import UIKit

class ReportController: BaseViewController {

    @IBOutlet weak var reasonPopupBtn: UIButton!
    let reasons = [
        "Bad Service",
        "Late Arrival",
        "Missed Appointment",
        "Service Not Completed as Requested",
        "Service Took Longer Than Promised",
        "Rude or Unprofessional Behavior",
        "Lack of Transparency About Costs or Process",
        "Left Worksite Messy or Hazardous",
        "Damaged Property",
        "Stole or Misused Customer Items",
        "Poor Follow-Up After Service"
    ]
    var serviceName: String?
    var userName: String?
    var selectedReason = "(no reason provided)"
    let reportManager = ServiceReportManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reasonPopupBtn == nil {
            return
        }
        
        let reasonDelegate = {[weak self] (action : UIAction) in
            self!.selectedReason = action.title
        }
        
        var actions: [UIAction] = []
        for r in reasons {
            actions.append(UIAction(title: r, handler: reasonDelegate))
        }
        reasonPopupBtn.menu = UIMenu(children: actions)
        reasonPopupBtn.showsMenuAsPrimaryAction = true
        reasonPopupBtn.changesSelectionAsPrimaryAction = true
    }
    
    

    @IBAction func reportSubmit(_ sender: Any) {
        reportManager.saveReport(ServiceReport(serviceName: serviceName!, userName: userName!, reason: selectedReason)) { [weak self] result in
            switch result {
            case .success(_):
                self!.navigationController?.popViewController(animated: true)
                self!.showAlert(message: "Report sent", title: "Success")
            case .failure(_):
                self!.showAlert(message: "An error occured. Try again", title: "")
            }
        }
    }
    
    private func showAlert(message: String, title: String = "Validation Error") {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func reportCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
