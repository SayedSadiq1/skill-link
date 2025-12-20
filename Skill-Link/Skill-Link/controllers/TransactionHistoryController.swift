//
//  TransactionHistoryController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//
import UIKit

class TransactionHistoryController: BaseViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

        private var transactions: [Transaction] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            setupTableView()
            loadDummyData()
        }

        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
        }

        private func loadDummyData() {
            transactions = [
                Transaction(id: "1", amount: 25.0, serviceId: "Plumbing", method: "Visa", createdAt: "20 Dec 2025"),
                Transaction(id: "2", amount: 15.5, serviceId: "Cleaning", method: "Cash", createdAt: "18 Dec 2025"),
                Transaction(id: "3", amount: 40.0, serviceId: "Electrical", method: "Apple Pay", createdAt: "15 Dec 2025"),
                Transaction(id: "1", amount: 25.0, serviceId: "Plumbing", method: "Visa", createdAt: "20 Dec 2025"),
                Transaction(id: "2", amount: 15.5, serviceId: "Cleaning", method: "Cash", createdAt: "18 Dec 2025"),
                Transaction(id: "3", amount: 40.0, serviceId: "Electrical", method: "Apple Pay", createdAt: "15 Dec 2025"),
                Transaction(id: "1", amount: 25.0, serviceId: "Plumbing", method: "Visa", createdAt: "20 Dec 2025"),
                Transaction(id: "2", amount: 15.5, serviceId: "Cleaning", method: "Cash", createdAt: "18 Dec 2025"),
                Transaction(id: "3", amount: 40.0, serviceId: "Electrical", method: "Apple Pay", createdAt: "15 Dec 2025")
            ]

            tableView.reloadData()
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return transactions.count
       }

       func tableView(_ tableView: UITableView,
                      cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(
               withIdentifier: "TransactionCell",
               for: indexPath
           ) as! TransactionCell

           cell.configure(with: transactions[indexPath.row])
           cell.selectionStyle = .none
           return cell
       }
}
