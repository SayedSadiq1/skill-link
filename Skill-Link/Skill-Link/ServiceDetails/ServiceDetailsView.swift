//
//  ServiceDetailsView.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 08/12/2025.
//

import UIKit

class ServiceDetailsView: UIViewController {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI() {
        categoryLabel.layer.borderWidth = 1
    }
}
