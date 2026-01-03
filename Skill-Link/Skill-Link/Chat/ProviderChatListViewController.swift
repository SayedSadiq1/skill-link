//
//  ProviderChatListViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 03/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderChatListViewController: BaseViewController,
                                      UITableViewDataSource,
                                      UITableViewDelegate,
                                      UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    struct ChatRow {
        let chatId: String
        let title: String          // seeker name
        let lastMessage: String?
        let lastMessageTime: Timestamp?
    }

    private var chatsListener: ListenerRegistration?

    var chattedChats: [ChatRow] = []
    var displayedChats: [ChatRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search chats"
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.tableFooterView = UIView()

        listenToUserChats()
    }

    // MARK: - Firestore Listener

    func listenToUserChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("❌ Provider not authenticated")
            return
        }

        chatsListener?.remove()

        chatsListener = Firestore.firestore()
            .collection("Chats")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Chat listener error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let chats: [ChatRow] = documents.compactMap { doc in
                    let data = doc.data()

                    let participants = data["participants"] as? [String] ?? []
                    guard participants.count == 2 else { return nil }

                    let seekerName = data["seekerName"] as? String ?? "Seekertest"

                    return ChatRow(
                        chatId: doc.documentID,
                        title: seekerName,
                        lastMessage: data["lastMessage"] as? String,
                        lastMessageTime: data["lastMessageTime"] as? Timestamp
                    )
                }

                let sorted = chats.sorted {
                    ($0.lastMessageTime?.seconds ?? 0) >
                    ($1.lastMessageTime?.seconds ?? 0)
                }

                DispatchQueue.main.async {
                    self.chattedChats = sorted
                    self.displayedChats = sorted
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        displayedChats.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatListCell",
            for: indexPath
        ) as! ChatListCell

        let chat = displayedChats[indexPath.row]

        let timeText: String
        if let ts = chat.lastMessageTime {
            timeText = ts.dateValue()
                .formatted(date: .omitted, time: .shortened)
        } else {
            timeText = ""
        }

        cell.configure(
            name: chat.title,
            lastMessage: chat.lastMessage ?? "Start chatting",
            time: timeText
        )

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let chat = displayedChats[indexPath.row]
        openChat(chatId: chat.chatId, title: chat.title)
    }

    func openChat(chatId: String, title: String) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "ProviderChatViewController"
        ) as! ProviderChatViewController

        vc.chatId = chatId
        vc.chatTitle = title

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Search

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        let text = searchText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            displayedChats = chattedChats
        } else {
            displayedChats = chattedChats.filter {
                $0.title.lowercased().contains(text) ||
                ($0.lastMessage?.lowercased().contains(text) ?? false)
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
