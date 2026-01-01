//
//  SeekerHomeViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

class SeekerHomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func messagesTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "ChatNav")
        
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
