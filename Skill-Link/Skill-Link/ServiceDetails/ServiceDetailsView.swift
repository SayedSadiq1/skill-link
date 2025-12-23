//
//  ServiceDetailsView.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 08/12/2025.
//

import UIKit

class ServiceDetailsView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    let categories = ["Home Maintenance", "Handwork", "Electricity"]
    let isProvider: Bool = true
    
    @IBOutlet weak var reportStackView: UIStackView!
    @IBOutlet weak var pricingPopupBtn: UIButton!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var categoryPopupBtn: UIButton!
    
    func setupUI() {
        if (!isProvider) {
            return
        }
        
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
        
        if actionBtn != nil {
            actionBtn.setTitle("Edit service", for: .normal)
            actionBtn.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        if cancelBtn != nil {
            cancelBtn.setTitle("Deactivate", for: .normal)
            cancelBtn.setImage(UIImage(systemName: "xmark.app"), for: .normal)
        }
        
    }
    
    @IBAction func reportClicked(_ sender: UIButton) {
        reportStackView.isHidden = false
    }
    
    
    @IBAction func actionClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
        
        if !isProvider {
            let controller = storyboard.instantiateViewController(withIdentifier: "serviceBookingViewController")
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
            return
        }
        
        let controller2 = storyboard.instantiateViewController(withIdentifier: "editServiceView")
        controller2.modalPresentationStyle = .fullScreen
        self.present(controller2, animated: true)
    }
    
    // 1. Enable user interaction on the ImageView
    @IBOutlet weak var returnImageView: UIImageView! {
        didSet {
            returnImageView.isUserInteractionEnabled = true
            
            // 2. Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleReturnTap))
            returnImageView.addGestureRecognizer(tapGesture)
        }
    }

    // 3. Handle the tap action
    @objc private func handleReturnTap() {
        // Perform your return action
        //navigationController?.popViewController(animated: true)
        
        // Or if presented modally:
        dismiss(animated: true, completion: nil)
    }
}
