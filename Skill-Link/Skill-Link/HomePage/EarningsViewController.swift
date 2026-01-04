//
//  EarningsViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class EarningsViewController: BaseViewController {

    @IBOutlet weak var totalEarningLabel: UILabel!
    @IBOutlet weak var completedJobsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private struct PaymentRow {
        let userId: String
        let date: Date
        let totalPrice: Double
        let method: String
    }

    private let db = Firestore.firestore()
    private var rows: [PaymentRow] = []

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        loadEarnings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEarnings()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    private func loadEarnings() {
        guard let providerId = Auth.auth().currentUser?.uid else { return }

        // Use completed bookings as "payment history"
        db.collection("Booking")
            .whereField("providerId", isEqualTo: providerId)
            .whereField("status", isEqualTo: "Completed") // change if your completed status differs
            .getDocuments { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("Earnings load error: \(error)")
                    self.updateHeader(total: 0, count: 0)
                    self.rows = []
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    return
                }

                let docs = snap?.documents ?? []

                var tmp: [PaymentRow] = []
                tmp.reserveCapacity(docs.count)

                for doc in docs {
                    let d = doc.data()

                    let userId = d["userId"] as? String ?? "User"
                    let totalPrice = Self.doubleValue(d["totalPrice"])
                    let method = d["paymentMethod"] as? String ?? "Cash" // optional field

                    let date: Date
                    if let ts = d["date"] as? Timestamp {
                        date = ts.dateValue()
                    } else {
                        date = Date()
                    }

                    tmp.append(PaymentRow(userId: userId, date: date, totalPrice: totalPrice, method: method))
                }

                // Sort newest first
                tmp.sort { $0.date > $1.date }

                let total = tmp.reduce(0.0) { $0 + $1.totalPrice }
                self.rows = tmp

                DispatchQueue.main.async {
                    self.updateHeader(total: total, count: tmp.count)
                    self.tableView.reloadData()
                }
            }
    }

    private func updateHeader(total: Double, count: Int) {
        totalEarningLabel.text = String(format: "%.2f BD", total)
        completedJobsLabel.text = "\(count) Completed Jobs"
    }

    private static func doubleValue(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let s = any as? String, let d = Double(s) { return d }
        return 0
    }
}

// MARK: - UITableViewDataSource & Delegate
extension EarningsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        let row = rows[indexPath.row]

        let dateText = dateFormatter.string(from: row.date)

        // For now we show userId (safe + always available). If you want name later, we can fetch User doc.
        cell.configure(
            userText: row.userId,
            dateText: dateText,
            amount: row.totalPrice,
            method: row.method
        )

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
