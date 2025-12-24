//
//  ReportsController.swift
//  Skill-Link
//
//  Created by Sayed Sadiq on 22/12/2025.
//

import UIKit

class ReportsController: BaseViewController,
                         UITableViewDelegate,
                         UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Model
    struct Report {
        let title: String
        let service: String
        let reason: String
        let status: String
    }

    // MARK: - Data
    let reports: [Report] = [
        Report(title: "Report 1",
               service: "Plumbing Service",
               reason: "Late",
               status: "Pending"),
        Report(title: "Report 2",
               service: "Electrical Service",
               reason: "No Show",
               status: "Reviewed")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = 200
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReportCell",
            for: indexPath
        ) as! ReportCell

        let report = reports[indexPath.row]

        cell.configure(with: report)
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // optional: handle tap
    }
}
