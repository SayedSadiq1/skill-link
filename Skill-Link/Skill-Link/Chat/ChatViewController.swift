//
//  ChatViewController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 28/12/2025.
//

import UIKit

class ChatViewController: BaseViewController,
                          UITableViewDataSource,
                          UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!


    struct Message {
        let text: String
        let isMine: Bool
    }

    var messages: [Message] = [
        Message(text: "Hi", isMine: false),
        Message(text: "Hello 👋", isMine: true),
        Message(text: "How are you?", isMine: false),
        Message(text: "All good, working on the chat UI", isMine: true),
        Message(text: "Looks clean 👍", isMine: false)
    ]

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
              !text.isEmpty else {
            return
        }

        sendButton.isEnabled = false

        let newMessage = Message(text: text, isMine: true)
        messages.append(newMessage)

        messageTextField.text = ""

        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        sendButton.isEnabled = true
    }
    
    

}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
