//
//  ReportController.swift
//  Skill-Link
//
//  Created by BP-36-213-11 on 23/12/2025.
//

import UIKit

class ReportController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var reportDescriptionTextView: UITextView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func reportSubmit(_ sender: Any) {
    }
    @IBAction func reportCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
