//
//  ViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 01/12/2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

