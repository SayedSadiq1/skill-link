//
//  ChatListViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 31/12/2025.
//

import UIKit
import FirebaseFirestore

class ChatListViewController: BaseViewController,
                              UITableViewDataSource,
                              UITableViewDelegate,
                              UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    
    struct Provider {
        let id: String
        let fullName: String
        let serviceName: String

        // Chat-related (optional)
        let lastMessage: String?
        let lastMessageTime: String?
    }
    
    // All providers from Firebase
    var allProviders: [Provider] = []

    // Providers user already chatted with (subset of allProviders)
    var chattedProviders: [Provider] = []

    // What the table shows
    var displayedProviders: [Provider] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chats"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.tableFooterView = UIView()

        searchBar.delegate = self
        searchBar.placeholder = "Search providers"

        fetchAllProviders()
    }

    func fetchAllProviders() {
        let db = Firestore.firestore()

        db.collection("User")
            .whereField("role", isEqualTo: "provider")
            .whereField("profileCompleted", isEqualTo: true)
            .getDocuments { snapshot, error in

                guard let documents = snapshot?.documents else { return }

                self.allProviders = documents.map { doc in
                    let data = doc.data()

                    return Provider(
                        id: doc.documentID,
                        fullName: data["fullName"] as? String ?? "",
                        serviceName: data["serviceName"] as? String ?? "",
                        lastMessage: nil,
                        lastMessageTime: nil
                    )
                }

                self.mergeChats()
            }
    }
    
    func mergeChats() {
        // Sample existing chats
        let existingChats: [String: (String, String)] = [
            "provider_id_1": ("Hey, how are you?", "10:42 AM"),
            "provider_id_2": ("Let’s meet tomorrow", "Yesterday")
        ]

        chattedProviders = allProviders.map { provider in
            if let chat = existingChats[provider.id] {
                return Provider(
                    id: provider.id,
                    fullName: provider.fullName,
                    serviceName: provider.serviceName,
                    lastMessage: chat.0,
                    lastMessageTime: chat.1
                )
            } else {
                return provider
            }
        }
        .filter { $0.lastMessage != nil }

        // Default state = chatted providers only
        displayedProviders = chattedProviders
        tableView.reloadData()
    }


    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        displayedProviders.count
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatListCell",
            for: indexPath
        ) as! ChatListCell

        let provider = displayedProviders[indexPath.row]

        cell.configure(
            name: provider.fullName,
            lastMessage: provider.lastMessage ?? provider.serviceName,
            time: provider.lastMessageTime ?? ""
        )

        return cell
    }


    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let provider = displayedProviders[indexPath.row]

        if provider.lastMessage == nil {
            print("Start NEW chat with \(provider.fullName)")
        } else {
            print("Open EXISTING chat with \(provider.fullName)")
        }
    }


    // MARK: - Search

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        let text = searchText.lowercased().trimmingCharacters(in: .whitespaces)

        if text.isEmpty {
            // Default → only providers you already chatted with
            displayedProviders = chattedProviders
        } else {
            // Search → ALL providers
            displayedProviders = allProviders.filter {
                $0.fullName.lowercased().contains(text) ||
                $0.serviceName.lowercased().contains(text)
            }
        }

        tableView.reloadData()
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
