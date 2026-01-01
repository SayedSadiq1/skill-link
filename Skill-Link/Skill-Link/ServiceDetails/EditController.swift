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
    var selectedCategory: String?
    var selectedPricingType: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        setCategories()
        setupUI()
    }
    
    var categories: [String] = ["Loading"]
    var service: Service?
    let serviceManager = ServiceManager()

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
        
        setCategoryOptions()
        var pricingActions: [UIAction] = []
        for action in ["Fixed", "Hourly"] {
            pricingActions.append(UIAction(title: action, state: action == service.priceType.rawValue ? .on : .off, handler: {(uiaction : UIAction) in self.selectedPricingType = uiaction.title}))
        }
        pricingPopupBtn.menu = UIMenu(children: pricingActions)
    }
    
    func setCategories() {
        serviceManager.fetchServiceCategories(completion: {result in
            switch result {
            case .success(let categories):
                self.categories = categories
                self.setCategoryOptions()
            case .failure(let error):
                self.categories = ["Home Maintenance"]
                print("Error fetching categories: \(error.localizedDescription)")
            }
        })
    }
    
    func setCategoryOptions() {
        guard let service = service else {
            return
        }
        var actions: [UIAction] = []
        for action in categories {
            actions.append(UIAction(title: action, state: action == service.category ? .on : .off, handler: {(uiaction : UIAction) in self.selectedCategory = uiaction.title}))
        }
        categoryPopupBtn.menu = UIMenu(children: actions)
    }
    
    func initWithService(service: Service) {
        self.service = service
    }

    @IBAction func save(_ sender: Any) {
        service?.category = selectedCategory ?? categories[0]
        if titleField.text == nil || titleField.text?.count == 0 {
            showAlert(message: "Title cannot be empty")
            return
        }
        service?.title = titleField.text!
        if service?.description == nil || service?.description.count == 0 {
            showAlert(message: "Description cannot be empty")
            return
        }
        service?.description = descriptionField.text
        if let minDuration = Double(minDurationField.text!), minDuration >= 0 {
            service?.durationMinHours = minDuration
        } else {
            showAlert(message: "Invalid minimum duration for service")
            return
        }
        if let maxDuration = Double(maxDurationField.text!),
           maxDuration >= service!.durationMinHours {
            service?.durationMaxHours = maxDuration
        } else {
            showAlert(message: "Invalid maximum duration for service\nMust be more than minimum duration")
            return
        }
        if let priceBD = Double(pricingField.text!) {
            service?.priceBD = priceBD
        } else {
            showAlert(message: "Invalid price")
            return
        }
        service?.priceType = PriceType(rawValue: selectedPricingType ?? "Hourly")!
        if disclaimersField.text.count > 0 {
            service?.disclaimers = disclaimersField.text.components(separatedBy: "\n")
        }
        
        self.navigationController?.popViewController(animated: true)
        showAlert(message: "Successfully saved!", title: "Edit Service")
    }
    
    private func showAlert(message: String, title: String = "Validation Error") {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
