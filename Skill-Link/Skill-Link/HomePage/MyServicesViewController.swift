//
//  MyServicesViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

struct MyServiceItem {
    let docId: String
    let title: String
    let category: String
    let availableAt: String
    var available: Bool
}

final class MyServicesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBAction func addServiceTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toAddService", sender: nil)
        }

    private let db = Firestore.firestore()
    private var services: [MyServiceItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // DO NOT set title or add nav buttons (you said it breaks your theme)
        setupTable()
        loadMyServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMyServices()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        // you are using storyboard prototype cell
        tableView.separatorStyle = .none
    }


    private func loadMyServices() {
        guard let providerId = Auth.auth().currentUser?.uid else {
            services = []
            tableView.reloadData()
            return
        }

        db.collection("Service")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }

                if let error = error {
                    self.showAlert("Error", error.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []
                self.services = docs.map { doc in
                    let d = doc.data()
                    return MyServiceItem(
                        docId: doc.documentID,
                        title: d["title"] as? String ?? "Untitled",
                        category: d["category"] as? String ?? "",
                        availableAt: d["availableAt"] as? String ?? "",
                        available: d["available"] as? Bool ?? false
                    )
                }

                self.tableView.reloadData()
            }
    }

    private func toggleAvailability(docId: String, newValue: Bool) {
        db.collection("Service").document(docId).updateData(["available": newValue]) { [weak self] error in
            if let error = error {
                self?.showAlert("Error", error.localizedDescription)
                return
            }
            self?.loadMyServices()
        }
    }

    private func showAlert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // MUST match storyboard cell identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyServiceCell", for: indexPath)

        guard let myCell = cell as? MyServiceCell else {
            return cell
        }

        let item = services[indexPath.row]
        myCell.configure(
            title: item.title,
            category: item.category,
            availableAt: item.availableAt,
            available: item.available
        )

        myCell.onToggle = { [weak self] in
            self?.toggleAvailability(docId: item.docId, newValue: !item.available)
        }

        return myCell
    }
}
