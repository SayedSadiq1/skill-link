//
//  ServiceDetailsView.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 08/12/2025.
//

import UIKit

class ServiceDetailsView: UIViewController {
    @IBOutlet weak var headerStackVIew: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    let isProvider: Bool = true
    
    @IBOutlet weak var reportStackView: UIStackView!
    
    func setupUI() {
        if (!isProvider) {
            return
        }
        
        actionBtn.setTitle("Edit service", for: .normal)
        actionBtn.setImage(UIImage(systemName: "pencil"), for: .normal)
        cancelBtn.setTitle("Deactivate", for: .normal)
        cancelBtn.setImage(UIImage(systemName: "xmark.app"), for: .normal)
    }
    
    @IBAction func reportClicked(_ sender: UIButton) {
        reportStackView.isHidden = false
    }
    
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
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
}
