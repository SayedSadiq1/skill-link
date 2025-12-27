//
//  UserManagementController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 21/12/2025.
//
import UIKit

class UserManagementController : BaseViewController,
                                 UITableViewDelegate,
                                 UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    struct User {
        let name: String
        let role: String
        let status: String
    }

    // SAMPLE DATA (replace with real API later)
    let users: [User] = [
        User(name: "Sayed Hussain", role: "Provider", status: "Active"),
        User(name: "Ali Ahmed", role: "Provider", status: "Suspend")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // 🔧 FIX unwanted top spacing
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0   // iOS 15+
        tableView.rowHeight = 100

    }


    // MARK: - TableView

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as! UserCell

        let user = users[indexPath.row]

        cell.nameLabel.text = user.name
        cell.roleLabel.text = user.role
        cell.statusLabel.text = user.status

        cell.actionButton.setTitle("Suspend", for: .normal)

        return cell
    }
}
