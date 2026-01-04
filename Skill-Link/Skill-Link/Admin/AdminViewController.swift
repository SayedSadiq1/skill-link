//
//  AdminViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 21/12/2025.
//

import UIKit
import Firebase
import FirebaseFirestore


class AdminViewController: BaseViewController {
    
    @IBOutlet weak var totalUsersLabel: UILabel!
    @IBOutlet weak var activeProvidersLabel: UILabel!
    @IBOutlet weak var activeBookingsLabel: UILabel!
    @IBOutlet weak var reportedCasesLabel: UILabel!
    @IBOutlet weak var pendingVerificationsLabel: UILabel!
    
    private let db = Firestore.firestore()


    override func viewDidLoad() {
        super.viewDidLoad()

        print(FirebaseApp.app() != nil ? "Firebase connected" : "Firebase not connected")

        // Total users (already working)
        db.collection("User").getDocuments { snapshot, error in
            let count = snapshot?.documents.count ?? 0
            DispatchQueue.main.async {
                self.totalUsersLabel.text = "\(count)"
            }
        }

        fetchActiveProviders()
        fetchActiveBookings()
        fetchReportedCases()

        // Pending verifications removed
        pendingVerificationsLabel.isHidden = true
    }

    
    
    func fetchActiveProviders() {
        db.collection("User")
            .whereField("role", isEqualTo: "provider")
            .whereField("isSuspended", isEqualTo: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Active providers error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.activeProvidersLabel.text = "\(count)"
                }
            }
    }
    
    func fetchActiveBookings() {
        db.collection("Booking")
            .whereField("status", isEqualTo: "Upcoming")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Active bookings error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.activeBookingsLabel.text = "\(count)"
                }
            }
    }
    
    func fetchReportedCases() {
        db.collection("Report")
            .whereField("status", isEqualTo: "Pending")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("❌ Reported cases error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.reportedCasesLabel.text = "\(count)"
                }
            }
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
