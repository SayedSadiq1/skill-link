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
    let available: Bool
}

final class MyServicesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var services: [MyServiceItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        loadMyServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMyServices() // ✅ refresh after disable/reactivate in details
    }

    // MARK: - Add Service (keep your existing segue if you already have one)
    @IBAction func addServiceTapped(_ sender: UIButton) {
        // If you have a segue already, keep using it:
        performSegue(withIdentifier: "toAddService", sender: nil)

        // If you DON'T have a segue, comment the line above and use push:
        // let vc = storyboard?.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
        // navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180

        // ✅ Force programmatic cell (prevents “only Active shows”)
        tableView.register(MyServiceCell.self, forCellReuseIdentifier: "MyServiceCell")
    }

    // MARK: - Firestore Load
    private func loadMyServices() {
        guard let providerId = Auth.auth().currentUser?.uid else {
            services = []
            DispatchQueue.main.async { self.tableView.reloadData() }
            return
        }

        db.collection("Service")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { [weak self] snap, error in
                guard let self else { return }

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

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - Open Details (fetch full Service object)
    private func openServiceDetails(serviceDocId: String) {
        let manager = ServiceManager()
        manager.fetchService(by: serviceDocId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let svc):
                let serviceDetailsStoryboard = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
                if let serviceDetails = serviceDetailsStoryboard.instantiateViewController(withIdentifier: "serviceDetailsPage") as? ServiceDetailsViewController {
                    let serviceManager = ServiceManager()
                    serviceManager.fetchService(by: serviceDocId) {[weak self] result in
                        switch result {
                        case .success(let success):
                            serviceDetails.service = success
                            serviceDetails.navigationItem.title = "Service Details"
                            self!.navigationController?.pushViewController(serviceDetails, animated: true)
                        case .failure(let failure):
                            print("Error getting service details: \(failure.localizedDescription)")
                        }}
                    
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert("Error", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MyServiceCell", for: indexPath) as! MyServiceCell

        let item = services[indexPath.row]
        cell.configure(title: item.title, category: item.category, availableAt: item.availableAt, available: item.available)

        cell.onViewDetails = { [weak self] in
            self?.openServiceDetails(serviceDocId: item.docId)
        }

        return cell
    }

    // MARK: - Alert
    private func showAlert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
