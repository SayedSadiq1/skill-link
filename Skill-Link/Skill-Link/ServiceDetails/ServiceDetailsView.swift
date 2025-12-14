//
//  ServiceDetailsView.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 08/12/2025.
//

import UIKit

class ServiceDetailsView: UIViewController {
    
    @IBOutlet weak var titleStackView: UIStackView!
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        titleStackView.layer.borderWidth = 10
        titleStackView.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
}
