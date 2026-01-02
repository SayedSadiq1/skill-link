//
//  ChatListViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 31/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
        let lastMessageTime: Timestamp?
    }
    
    private var chatsListener: ListenerRegistration?
    
    // All providers from Firebase
    var allProviders: [Provider] = []

    // Providers user already chatted with (subset of allProviders)
    var chattedProviders: [Provider] = []

    // What the table shows
    var displayedProviders: [Provider] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchBarStyle = .minimal

//        title = "Chats"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.tableFooterView = UIView()

        searchBar.delegate = self
        searchBar.placeholder = "Search providers"

//        ensureAuthThenFetchProviders()
        fetchAllProviders()

    }
    
    func ensureAuthThenFetchProviders() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { [weak self] result, error in
                if let error = error {
                    print("Anonymous auth failed:", error.localizedDescription)
                    return
                }

                print("Anonymous user signed in:", result?.user.uid ?? "")
                self?.fetchAllProviders()
            }
        } else {
            fetchAllProviders()
        }
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

                self.listenToUserChats()

            }
    }
    
    func listenToUserChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Remove old listener if exists
        chatsListener?.remove()

        chatsListener = Firestore.firestore()
            .collection("Chats")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { snapshot, error in

                guard let documents = snapshot?.documents else {
                    print("Chat listener error:", error?.localizedDescription ?? "")
                    return
                }

                let providerMap = Dictionary(uniqueKeysWithValues: self.allProviders.map {
                    ($0.id, $0)
                })

                let chats = documents.compactMap { doc -> Provider? in
                    let data = doc.data()
                    let participants = data["participants"] as? [String] ?? []

                    let otherIds = participants.filter { $0 != currentUserId }
                    guard let pid = otherIds.first else { return nil }

                    let provider = providerMap[pid] ?? Provider(
                        id: pid,
                        fullName: "Unknown Provider",
                        serviceName: "",
                        lastMessage: nil,
                        lastMessageTime: nil
                    )

                    return Provider(
                        id: pid,
                        fullName: provider.fullName,
                        serviceName: provider.serviceName,
                        lastMessage: data["lastMessage"] as? String,
                        lastMessageTime: data["lastMessageTime"] as? Timestamp
                    )
                }
                
                let sortedChats = chats.sorted {
                    ($0.lastMessageTime?.seconds ?? 0) >
                    ($1.lastMessageTime?.seconds ?? 0)
                }


                DispatchQueue.main.async {
                    self.chattedProviders = sortedChats

                    if self.searchBar.text?.isEmpty == true {
                        self.displayedProviders = sortedChats
                    }

                    self.tableView.reloadData()
                }

            }
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

        let timeText: String
        if let ts = provider.lastMessageTime {
            timeText = ts.dateValue()
                .formatted(date: .omitted, time: .shortened)
        } else {
            timeText = "Go to chat"
        }

        cell.configure(
            name: provider.fullName,
            lastMessage: provider.lastMessage ?? provider.serviceName,
            time: timeText
        )

        return cell
    }



    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let provider = displayedProviders[indexPath.row]
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        // 🔑 Deterministic chat ID (prevents duplicates)
        let pairId = [currentUserId, provider.id]
            .sorted()
            .joined(separator: "_")

        let chatRef = db.collection("Chats").document(pairId)

        chatRef.getDocument { doc, error in
            if doc?.exists == true {
                // Existing chat
                self.openChat(chatId: pairId, provider: provider)
            } else {
                // Create chat ONCE
                chatRef.setData([
                    "participants": [currentUserId, provider.id],
                    "pairId": pairId,
                    "createdAt": Timestamp(),
                    "lastMessage": "",
                    "lastMessageTime": Timestamp(),
                    "lastSenderId": ""
                ]) { _ in
                    self.openChat(chatId: pairId, provider: provider)
                }
            }
        }
    }

    
    func openChat(chatId: String, provider: Provider) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "ChatViewController"
        ) as! ChatViewController

        vc.chatId = chatId
        vc.providerId = provider.id
        vc.providerName = provider.fullName

        navigationController?.pushViewController(vc, animated: true)
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
    
    deinit {
        chatsListener?.remove()
    }

}
