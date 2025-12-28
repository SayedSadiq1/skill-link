//
//  SearchResultViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

class SearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private let services: [Service] = [
        Service(id: "1", name: "Professional Plumbing Service", category: "Plumbing", priceBD: 70, rating: 5.0, providerName: "Ali Yusuf"),
        Service(id: "2", name: "Electrician Home Wiring", category: "Electrician", priceBD: 50, rating: 4.6, providerName: "Ahmed Raza"),
        Service(id: "3", name: "Deep Cleaning Service", category: "Cleaning", priceBD: 40, rating: 4.8, providerName: "Sara Ali")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCellTableViewCell

       

    
        let service = services[indexPath.row]
        cell.serviceNameLabel.text = service.name
        cell.priceLabel.text = "\(Int(service.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", service.rating)
        return cell

    }
}
