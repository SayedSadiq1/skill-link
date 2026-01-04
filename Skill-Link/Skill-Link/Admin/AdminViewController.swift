//
//  AdminViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 21/12/2025.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth


class AdminViewController: BaseViewController {
    
    @IBOutlet weak var totalUsersLabel: UILabel!
    @IBOutlet weak var activeProvidersLabel: UILabel!
    @IBOutlet weak var activeBookingsLabel: UILabel!
    @IBOutlet weak var reportedCasesLabel: UILabel!
    
    private var usersListener: ListenerRegistration?
    private var providersListener: ListenerRegistration?
    private var bookingsListener: ListenerRegistration?
    private var reportsListener: ListenerRegistration?

    
    private let db = Firestore.firestore()


    override func viewDidLoad() {
        super.viewDidLoad()

        print(FirebaseApp.app() != nil ? "Firebase connected" : "Firebase not connected")

        listenTotalUsers()
        listenActiveProviders()
        listenActiveBookings()
        listenReportedCases()

    }
    
    func listenTotalUsers() {
        usersListener = db.collection("User")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Total users error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.totalUsersLabel.text = "\(count)"
                }
            }
    }
    
    func listenActiveProviders() {
        providersListener = db.collection("User")
            .whereField("role", isEqualTo: "provider")
            .whereField("isSuspended", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Active providers error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.activeProvidersLabel.text = "\(count)"
                }
            }
    }
    
    func listenActiveBookings() {
        bookingsListener = db.collection("Booking")
            .whereField("status", isEqualTo: "Upcoming")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Active bookings error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.activeBookingsLabel.text = "\(count)"
                }
            }
    }
    
    func listenReportedCases() {
        reportsListener = db.collection("Report")
            .whereField("status", isEqualTo: "Pending")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Reported cases error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.reportedCasesLabel.text = "\(count)"
                }
            }
    }





    
    
    func fetchActiveProviders() {
        db.collection("User")
            .whereField("role", isEqualTo: "provider")
            .whereField("isSuspended", isEqualTo: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Active providers error:", error)
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
                    print("Active bookings error:", error)
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
                    print("Reported cases error:", error)
                    return
                }

                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.reportedCasesLabel.text = "\(count)"
                }
            }
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })

        present(alert, animated: true)
    }

    private func performSignOut() {
        do {
            // Firebase sign out
            try Auth.auth().signOut()

            LocalUserStore.clearProfile()

            goToStartPage()
        } catch {
            showAlert(title: "Error", message: "Failed to sign out. Please try again.")
        }
    }
    
    private func goToStartPage() {
        let sb = UIStoryboard(name: "login", bundle: nil)

        let startVC = sb.instantiateViewController(
            withIdentifier: "StartPageViewController"
        ) as! StartPageViewController

        navigationController?.setViewControllers([startVC], animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
