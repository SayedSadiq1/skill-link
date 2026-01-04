//
//  ReportsController.swift
//  Skill-Link
//
//  Created by Sayed Sadiq on 22/12/2025.
//

import UIKit
import FirebaseFirestore


struct ReportModel {
    let id: String
    let serviceName: String
    let reason: String
    let status: String
    let userName: String
    let providerId: String
    let reportedAt: Timestamp
}

class ReportsController: BaseViewController,
                         UITableViewDelegate,
                         UITableViewDataSource,
                         UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let db = Firestore.firestore()
    private var reportListener: ListenerRegistration?

    private var allReports: [ReportModel] = []
    private var filteredReports: [ReportModel] = []



    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = 200
        
        searchBar.delegate = self
        searchBar.placeholder = "Search reports..."
        searchBar.autocapitalizationType = .none
        
        listenToReports()
    }
    
    func formattedDate(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func applySearchFilter() {
        let text = searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        if text.isEmpty {
            filteredReports = allReports
        } else {
            filteredReports = allReports.filter {
                $0.serviceName.lowercased().contains(text) ||
                $0.reason.lowercased().contains(text) ||
                $0.userName.lowercased().contains(text) ||
                $0.status.lowercased().contains(text)
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchFilter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        applySearchFilter()
        searchBar.resignFirstResponder()
    }



    
    func suspendProvider(providerId: String, reportId: String) {
        let userRef = db.collection("User").document(providerId)
        let reportRef = db.collection("Report").document(reportId)

        db.runTransaction({ transaction, errorPointer in
            transaction.updateData(["isSuspended": true], forDocument: userRef)
            transaction.updateData(["status": "Reviewed"], forDocument: reportRef)
            return nil
        }) { error, _ in
            if let error = error {
                print("❌ Suspend failed:", error)
            } else {
                print("✅ Provider suspended")
            }
        }
    }

    
    
    func confirmSuspendProvider(_ report: ReportModel) {
        let alert = UIAlertController(
            title: "Suspend Provider",
            message: "This will suspend the service owner account.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Suspend", style: .destructive) { _ in
            self.suspendProvider(providerId: report.providerId, reportId: report.id)
        })

        present(alert, animated: true)
    }

    
    
    func updateReportStatus(_ reportId: String, status: String) {
        db.collection("Report")
            .document(reportId)
            .updateData([
                "status": status
            ])
    }

    
    func showReportDetails(for report: ReportModel) {
        let message = """
        Service: \(report.serviceName)
        Reported By: \(report.userName)
        Reason: \(report.reason)
        Status: \(report.status)
        Reported At: \(formattedDate(report.reportedAt))
        """

        let alert = UIAlertController(
            title: "Report Details",
            message: message,
            preferredStyle: .alert
        )

        if report.status == "Pending" {
            alert.addAction(UIAlertAction(title: "Mark as Reviewed", style: .default) { _ in
                self.updateReportStatus(report.id, status: "Reviewed")
            })

            alert.addAction(UIAlertAction(title: "Reject Report", style: .destructive) { _ in
                self.updateReportStatus(report.id, status: "Rejected")
            })

            if !report.providerId.isEmpty {
                alert.addAction(UIAlertAction(title: "Suspend Provider", style: .destructive) { _ in
                    self.confirmSuspendProvider(report)
                })
            }
        }

        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }


    
    func listenToReports() {
        reportListener = db.collection("Report")
            .order(by: "reportedAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Report listener error:", error)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.allReports = documents.map { doc in
                    let data = doc.data()

                    return ReportModel(
                        id: doc.documentID,
                        serviceName: data["serviceName"] as? String ?? "N/A",
                        reason: data["reason"] as? String ?? "N/A",
                        status: data["status"] as? String ?? "Pending",
                        userName: data["userName"] as? String ?? "Unknown",
                        providerId: data["providerId"] as? String ?? "",
                        reportedAt: data["reportedAt"] as? Timestamp ?? Timestamp()
                    )
                }

                self.applySearchFilter()
            }
    }



    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return filteredReports.count
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReportCell",
            for: indexPath
        ) as! ReportCell

        let report = filteredReports[indexPath.row]


        cell.configure(with: report)

        cell.onReviewTapped = { [weak self] in
            self?.showReportDetails(for: report)
        }

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // optional: handle tap
    }
    
    deinit {
        reportListener?.remove()
    }

}
