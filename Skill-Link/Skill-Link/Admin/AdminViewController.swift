//
//  AdminViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 21/12/2025.
//

import UIKit

class AdminViewController: BaseViewController {
    
    @IBOutlet weak var totalUsersLabel: UILabel!
    @IBOutlet weak var activeProvidersLabel: UILabel!
    @IBOutlet weak var activeBookingsLabel: UILabel!
    @IBOutlet weak var reportedCasesLabel: UILabel!
    @IBOutlet weak var pendingVerificationsLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        totalUsersLabel.text = "100"
        activeProvidersLabel.text = "87"
        activeBookingsLabel.text = "42"
        reportedCasesLabel.text = "3"
        pendingVerificationsLabel.text = "12"
    }
    
    func updateStats(
        totalUsers: Int,
        activeProviders: Int,
        activeBookings: Int,
        reportedCases: Int,
        pendingVerifications: Int
    ) {
        totalUsersLabel.text = "\(totalUsers)"
        activeProvidersLabel.text = "\(activeProviders)"
        activeBookingsLabel.text = "\(activeBookings)"
        reportedCasesLabel.text = "\(reportedCases)"
        pendingVerificationsLabel.text = "\(pendingVerifications)"
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
