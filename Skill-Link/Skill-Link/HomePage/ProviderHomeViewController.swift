//
//  ProviderHomeViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

class ProviderHomeViewController: BaseViewController {
    
    override var shouldShowBackButton: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func messagesTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "ProviderChatListView")
        
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(nav, animated: true)
    }

    @IBAction func bookingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "BookingsOverview", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "bookingsTabView")
        nav.navigationItem.title = "Bookings Overview"
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(nav, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Settings", bundle: nil) // ← storyboard file name
           let vc = sb.instantiateViewController(
               withIdentifier: "NotificationCenterViewController"
           ) as! NotificationCenterViewController
           navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func profileTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "login", bundle: nil) // storyboard file name
            let vc = sb.instantiateViewController(
                withIdentifier: "ProfileProviderViewController"
            ) as! ProfileProviderViewController
            navigationController?.pushViewController(vc, animated: true)
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
