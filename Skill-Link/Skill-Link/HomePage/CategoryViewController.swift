//
//  CategoryViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit
import FirebaseFirestore

final class CategoryViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Inputs/Outputs
    var filters = SearchFilters()
    var onApply: ((SearchFilters) -> Void)?

    // MARK: - Data
    private var categories: [String] = []
    private var selectedSet = Set<String>()   // ✅ local, always current

    private let db = Firestore.firestore()

    // Firestore location:
    // collection: metadata
    // document: service_categories
    // field: categories (array of strings)
    private let categoriesDocPath = (collection: "metadata",
                                    document: "service_categories",
                                    field: "categories")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        // ✅ Initialize local selected state from incoming filters
        selectedSet = Set(filters.selectedCategories)

        fetchCategories()
    }

    // MARK: - Actions
    @IBAction func applyTapped(_ sender: UIButton) {
        filters.selectedCategories = Array(selectedSet)
        onApply?(filters)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Firestore
    private func fetchCategories() {
        db.collection(categoriesDocPath.collection)
            .document(categoriesDocPath.document)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    self.showSimpleAlert(title: "Error", message: "Failed to load categories.\n\(error.localizedDescription)")
                    return
                }

                let arr = snapshot?.data()?[self.categoriesDocPath.field] as? [String] ?? []
                self.categories = arr

                // Optional: keep selection only for categories that still exist
                self.selectedSet = self.selectedSet.filter { arr.contains($0) }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - Helpers
    private func showSimpleAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // ✅ Must match storyboard identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let category = categories[indexPath.row]
        cell.textLabel?.text = category

        // ✅ show checkmark based on local state (not old filters)
        cell.accessoryType = selectedSet.contains(category) ? .checkmark : .none

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let category = categories[indexPath.row]

        // ✅ toggle immediately
        if selectedSet.contains(category) {
            selectedSet.remove(category)
        } else {
            selectedSet.insert(category)
        }

        // ✅ update UI instantly (no need to leave screen)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
