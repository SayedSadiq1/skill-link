//
//  ProviderChatViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 03/01/2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProviderChatViewController: BaseViewController,
                                  UITableViewDataSource,
                                  UITableViewDelegate,
                                  UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var titleName: UILabel!

    var chatId: String!
    var chatTitle: String!

    private let db = Firestore.firestore()

    struct Message {
        let text: String
        let isMine: Bool
    }

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard chatId != nil else {
            print("❌ chatId is nil")
            return
        }

        titleName.text = chatTitle

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension

        messageTextField.delegate = self

        listenForMessages()
    }
    
    

    // MARK: - Firestore

    func listenForMessages() {
        guard let chatId = chatId else { return }

        db.collection("Chats")
            .document(chatId)
            .collection("Messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Message listener error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.messages = documents.map { doc in
                    let data = doc.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let text = data["text"] as? String ?? ""

                    return Message(
                        text: text,
                        isMine: senderId == Auth.auth().currentUser?.uid
                    )
                }

                self.tableView.reloadData()

                if !self.messages.isEmpty {
                    let index = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
                }
            }
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatCell",
            for: indexPath
        ) as! ChatCell

        let msg = messages[indexPath.row]
        cell.configure(message: msg.text, isSender: msg.isMine)
        return cell
    }

    // MARK: - Send

    @IBAction func sendTapped(_ sender: UIButton) {
        guard
            let chatId = chatId,
            let text = messageTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty,
            let senderId = Auth.auth().currentUser?.uid
        else { return }

        let messageData: [String: Any] = [
            "text": text,
            "senderId": senderId,
            "createdAt": Timestamp(),
            "type": "text"
        ]

        let chatRef = db.collection("Chats").document(chatId)

        chatRef.collection("Messages").addDocument(data: messageData)
        chatRef.updateData([
            "lastMessage": text,
            "lastMessageTime": Timestamp(),
            "lastSenderId": senderId
        ])

        messageTextField.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
