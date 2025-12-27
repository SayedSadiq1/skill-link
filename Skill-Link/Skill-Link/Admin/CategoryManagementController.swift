//
//  CategoryManagementController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 24/12/2025.
//

import UIKit

class CategoryManagementController: BaseViewController,
                                   UITableViewDelegate,
                                   UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addCategoryTapped(_ sender: UIButton) {
        categories.append(Category(name: "New Category"))
//        tableView.reloadData()
        
    }


    struct Category {
        let name: String
    }

    var categories: [Category] = [
        Category(name: "Home Repair"),
        Category(name: "Plumbing"),
        Category(name: "Electrical")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 55
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell

        cell.nameLabel.text = categories[indexPath.row].name

        return cell
    }
}
