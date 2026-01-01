//
//  EditController.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 31/12/2025.
//

import UIKit

class EditController: BaseViewController {

    @IBOutlet weak var categoryPopupBtn: UIButton!
    @IBOutlet weak var pricingPopupBtn: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var minDurationField: UITextField!
    @IBOutlet weak var maxDurationField: UITextField!
    @IBOutlet weak var pricingField: UITextField!
    @IBOutlet weak var disclaimersField: UITextView!
    @IBOutlet weak var additionalInfoField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    let categories = ["Home Maintenance", "Handwork", "Electrical"]
    var service: Service?

    func setupUI() {
        if pricingPopupBtn != nil {
            let pricingPopupClosure = {(action : UIAction) in
                print(action.title)
            }
            pricingPopupBtn.menu = UIMenu(children: [
                UIAction(title: "Hourly", state: .on, handler: pricingPopupClosure),
                UIAction(title: "Fixed", handler: pricingPopupClosure)
            ])
            pricingPopupBtn.showsMenuAsPrimaryAction = true
            pricingPopupBtn.changesSelectionAsPrimaryAction = true
        }
        
        if categoryPopupBtn != nil {
            let categoryPopupClosure = {(action : UIAction) in
                print(action)}
            var actions: [UIAction] = []
            for action in categories {
                actions.append(UIAction(title: action, handler: categoryPopupClosure))
            }
            categoryPopupBtn.menu = UIMenu(children: actions)
            categoryPopupBtn.showsMenuAsPrimaryAction = true
            categoryPopupBtn.changesSelectionAsPrimaryAction = true
        }
        
        guard let service = service else {
            return
        }
        titleField.text = service.title
        descriptionField.text = service.description
        minDurationField.text = String(service.durationMinHours)
        maxDurationField.text = String(service.durationMaxHours)
        pricingField.text = String(service.priceBD)
        disclaimersField.text = service.disclaimers.joined(separator: "\n")
        
        var actions: [UIAction] = []
        for action in categories {
            actions.append(UIAction(title: action, state: action == service.category ? .on : .off, handler: {_ in }))
        }
        categoryPopupBtn.menu = UIMenu(children: actions)
        
        var pricingActions: [UIAction] = []
        for action in ["Fixed", "Hourly"] {
            pricingActions.append(UIAction(title: action, state: action == service.priceType.rawValue ? .on : .off, handler: {_ in}))
        }
        pricingPopupBtn.menu = UIMenu(children: pricingActions)
    }
    
    func initWithService(service: Service) {
        self.service = service
    }

}
