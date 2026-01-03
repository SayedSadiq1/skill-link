//
//  CategoryManagementController.swift
//  Skill-Link
//
//  Created by sayed sadiq on 24/12/2025.
//

import UIKit
import FirebaseFirestore


class CategoryManagementController: BaseViewController,
                                   UITableViewDelegate,
                                   UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addCategoryTapped(_ sender: UIButton) {
        showAddCategoryAlert()
    }

    


    private var categories: [String] = []
    
    private let db = Firestore.firestore()
    private var categoryListener: ListenerRegistration?



    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 55
        
        listenToCategories()
    }
    
    func deleteCategory(_ name: String) {
        db.collection("metadata")
            .document("service_categories")
            .updateData([
                "categories": FieldValue.arrayRemove([name])
            ])
    }

    
    func showDeleteCategoryAlert(name: String) {
        let alert = UIAlertController(
            title: "Delete Category",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteCategory(name)
        })

        present(alert, animated: true)
    }

    
    func updateCategory(oldName: String, newName: String) {
        let ref = db.collection("metadata").document("service_categories")

        ref.updateData([
            "categories": FieldValue.arrayRemove([oldName])
        ])

        ref.updateData([
            "categories": FieldValue.arrayUnion([newName])
        ])
    }

    
    func showEditCategoryAlert(oldName: String) {
        let alert = UIAlertController(
            title: "Edit Category",
            message: "Update category name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = oldName
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let rawName = alert.textFields?.first?.text else { return }

            let newName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !newName.isEmpty else { return }

            if self.isDuplicateCategory(newName, excluding: oldName) {
                self.showDuplicateError()
                return
            }

            self.updateCategory(oldName: oldName, newName: newName)
        })

        present(alert, animated: true)
    }

    
    func showAddCategoryAlert() {
        let alert = UIAlertController(
            title: "New Category",
            message: "Enter category name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Category name"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let rawName = alert.textFields?.first?.text else { return }

            let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return }

            if self.isDuplicateCategory(name) {
                self.showDuplicateError()
                return
            }

            self.addCategoryToFirestore(name)
        })


        present(alert, animated: true)
    }
    
    func addCategoryToFirestore(_ name: String) {
        db.collection("metadata")
            .document("service_categories")
            .updateData([
                "categories": FieldValue.arrayUnion([name])
            ])
    }
    
    func isDuplicateCategory(_ name: String, excluding oldName: String? = nil) -> Bool {
        let cleaned = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return categories.contains {
            let current = $0.lowercased()
            if let old = oldName?.lowercased(), current == old {
                return false
            }
            return current == cleaned
        }
    }
    
    func showDuplicateError() {
        let alert = UIAlertController(
            title: "Duplicate Category",
            message: "This category already exists.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }




    
    func listenToCategories() {
        categoryListener = db
            .collection("metadata")
            .document("service_categories")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Category listener error:", error)
                    return
                }

                guard
                    let data = snapshot?.data(),
                    let categoryArray = data["categories"] as? [String]
                else { return }

                DispatchQueue.main.async {
                    self.categories = categoryArray
                    self.tableView.reloadData()
                }
            }
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

        let category = categories[indexPath.row]
        cell.nameLabel.text = category

        // ✏️ EDIT
        cell.onEditTapped = { [weak self] in
            self?.showEditCategoryAlert(oldName: category)
        }

        // 🗑 DELETE
        cell.onDeleteTapped = { [weak self] in
            self?.showDeleteCategoryAlert(name: category)
        }

        return cell
    }

    
    deinit {
        categoryListener?.remove()
    }

}
