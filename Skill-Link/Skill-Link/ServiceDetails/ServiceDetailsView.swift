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
        setupUI()
        super.viewDidLoad()
    }
    
    func setupUI() {
        headerStackVIew.layer.borderWidth = 1
        headerStackVIew.layer.borderColor = UIColor.black.cgColor
    }
}
