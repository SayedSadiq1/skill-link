//
//  UserManagementController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 21/12/2025.
//
import UIKit
import FirebaseFirestore

struct UserModel {
    let id: String
    let fullName: String
    let role: String
    let isSuspended: Bool

    var statusText: String {
        return isSuspended ? "Suspended" : "Active"
    }
}


class UserManagementController : BaseViewController,
                                 UITableViewDelegate,
                                 UITableViewDataSource,
                                 UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!


    
    //
    private let db = Firestore.firestore()
    private var userListener: ListenerRegistration?
    
    private var allUsers: [UserModel] = []
    private var filteredUsers: [UserModel] = []



    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // 🔧 FIX unwanted top spacing
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0   // iOS 15+
        tableView.rowHeight = 100
        
        searchBar.delegate = self
        searchBar.placeholder = "Search users..."
        
        listenToUsers()

    }
    
    func listenToUsers() {
        userListener = db.collection("User")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Firestore listener error:", error)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.allUsers = documents.map { doc in
                    let data = doc.data()

                    return UserModel(
                        id: doc.documentID,
                        fullName: data["fullName"] as? String ?? "N/A",
                        role: data["role"] as? String ?? "user",
                        isSuspended: data["isSuspended"] as? Bool ?? false
                    )
                }

                self.applySearchFilter()
            }
    }





    // MARK: - TableView

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as! UserCell

        let user = filteredUsers[indexPath.row]


        cell.nameLabel.text = user.fullName
        cell.roleLabel.text = user.role.capitalized
        cell.statusLabel.text = user.statusText

        cell.actionButton.setTitle(
            user.isSuspended ? "Activate" : "Suspend",
            for: .normal
        )

        // 🔗 LINK BUTTON
        cell.onActionTapped = { [weak self] in
            self?.toggleSuspend(for: user)
        }

        return cell
    }
    
    func toggleSuspend(for user: UserModel) {
        db.collection("User")
            .document(user.id)
            .updateData([
                "isSuspended": !user.isSuspended
            ])
    }
    
    func applySearchFilter() {
        let text = searchBar.text?.lowercased() ?? ""

        if text.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter {
                $0.fullName.lowercased().contains(text) ||
                $0.role.lowercased().contains(text)
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



    
    deinit {
        userListener?.remove()
    }

}
