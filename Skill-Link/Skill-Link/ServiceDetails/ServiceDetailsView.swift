//
//  ServiceDetailsView.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 08/12/2025.
//

import UIKit

class ServiceDetailsView: UIViewController {
    
    @IBOutlet weak var TitleStackView: UIStackView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        TitleStackView.layer.borderWidth = 1
        TitleStackView.layer.masksToBounds = true
    }
}
