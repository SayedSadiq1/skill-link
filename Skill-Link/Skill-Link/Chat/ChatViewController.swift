//
//  ChatViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 28/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: BaseViewController,
                          UITableViewDataSource,
                          UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var titleName: UILabel!
    
    var chatId: String!
    var providerId: String!
    var providerName: String!

    private let db = Firestore.firestore()


    struct Message {
        let text: String
        let isMine: Bool
    }
    
    

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageTextField.delegate = self
        
//        title = providerName
        titleName.text = providerName
        listenForMessages()

    }
    
    func listenForMessages() {
        db.collection("Chats")
            .document(chatId)
            .collection("Messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in

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
        print("cell created")
        return cell
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        guard let text = messageTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let senderId = Auth.auth().currentUser?.uid else {
            return
        }

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

    
    

}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
