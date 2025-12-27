//
//  TransactionHistoryController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

import UIKit
import FirebaseAuth

final class TransactionHistoryController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var transactions: [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        Task {
            await loadData()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    private func loadData() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }

            let transactionsData = try await TransactionsController.shared.getTransactions(id: uid)
            self.transactions = transactionsData
            self.tableView.reloadData()

        } catch {
            print("DEBUG: Error loading transactions: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell",
                                                 for: indexPath) as! TransactionCell
        cell.configure(with: transactions[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
