//
//  ServiceManagementController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 26/12/2025.
//

import UIKit

class ServiceManagementController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    struct Service {
        let name: String
        let provider: String
        let category: String
        let rating: Float
    }

    var services: [Service] = [
        Service(name: "Home AC Repair", provider: "Ali Hassan", category: "Home Repair", rating: 4.0),
        Service(name: "Plumbing", provider: "John Doe", category: "Plumbing", rating: 3.5),
        Service(name: "Electrical", provider: "Jane Smith", category: "Electrical", rating: 4.5)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 180
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        let service = services[indexPath.row]
        cell.nameLabel.text = service.name
        cell.providerLabel.text = service.provider
        cell.categoryLabel.text = service.category
        cell.ratingLabel.text = "⭐️ " + String(service.rating)
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeService), for: .touchUpInside)
        
        return cell
    }
    
    @objc func removeService(sender: UIButton) {
        let index = sender.tag
        services.remove(at: index)
        tableView.reloadData()
    }
}
