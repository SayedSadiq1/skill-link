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
        Service(id: UUID.init(), title: "Example Service", description: "Description", category: "Tutor", priceBD: 30.5, priceType: .hourly, rating: 4.5, provider: UserProfile(name: "Ghassan", skills: [""], brief: "", contact: ""), available: true, disclaimers: [])
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
        cell.serviceNameLabel.text = service.title
        cell.priceLabel.text = "\(Int(service.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", service.rating)
        return cell

    }
}
