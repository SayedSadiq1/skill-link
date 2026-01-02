//
//  AddServiceTableViewController.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 02/01/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AddServiceTableViewController: UITableViewController {

    // MARK: - Firebase
    private let db = Firestore.firestore()

    // MARK: - Data
    private var categories: [String] = []
    private let availabilityOptions = ["Morning", "Afternoon", "Evening", "Night"]

    private var selectedCategory: String?
    private var selectedAvailability: String?

    private var serviceName = ""
    private var descriptionText = ""
    private var price: Double = 0
    private var minDuration: Double = 1
    private var maxDuration: Double = 1
    private var disclaimers: String = ""

    // MARK: - Sections
    enum Section: Int, CaseIterable {
        case basic
        case pickers
        case pricing
        case submit
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupTable()
        fetchCategories()
    }

    private func setupHeader() {
        title = "Add Service"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupTable() {
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Firebase
    private func fetchCategories() {
        db.collection("metadata").document("service_categories")
            .getDocument { [weak self] snap, _ in
                self?.categories = (snap?.data()?["categories"] as? [String]) ?? []
            }
    }

    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .basic: return 2
        case .pickers: return 2
        case .pricing: return 4
        case .submit: return 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .basic: return "Service Info"
        case .pickers: return "Options"
        case .pricing: return "Pricing"
        case .submit: return nil
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none

        switch Section(rawValue: indexPath.section)! {

        case .basic:
            cell.textLabel?.text = indexPath.row == 0 ? "Service Name" : "Description"
            cell.accessoryType = .disclosureIndicator

        case .pickers:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Category: \(selectedCategory ?? "Choose")"
            } else {
                cell.textLabel?.text = "Availability: \(selectedAvailability ?? "Choose")"
            }
            cell.accessoryType = .disclosureIndicator

        case .pricing:
            let titles = ["Price / Hour", "Min Duration", "Max Duration", "Disclaimers"]
            cell.textLabel?.text = titles[indexPath.row]
            cell.accessoryType = .disclosureIndicator

        case .submit:
            cell.textLabel?.text = "Add Service"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = .boldSystemFont(ofSize: 18)
            cell.textLabel?.textColor = .systemBlue
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        switch Section(rawValue: indexPath.section)! {

        case .pickers:
            if indexPath.row == 0 {
                showPicker(title: "Category", options: categories) {
                    self.selectedCategory = $0
                    tableView.reloadData()
                }
            } else {
                showPicker(title: "Availability", options: availabilityOptions) {
                    self.selectedAvailability = $0
                    tableView.reloadData()
                }
            }

        case .submit:
            saveService()

        default:
            break
        }
    }

    // MARK: - Save
    private func saveService() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let category = selectedCategory,
              let availability = selectedAvailability else {
            showAlert("Missing", "Fill all required fields")
            return
        }

        let data: [String: Any] = [
            "title": serviceName,
            "description": descriptionText,
            "category": category,
            "availableAt": availability,
            "priceBD": price,
            "priceType": "Hourly",
            "durationMinHours": minDuration,
            "durationMaxHours": maxDuration,
            "disclaimers": disclaimers.isEmpty ? [] : disclaimers.components(separatedBy: ","),
            "providerId": uid,
            "available": true,
            "rating": 0.0
        ]

        db.collection("Service").addDocument(data: data) { [weak self] error in
            if let error {
                self?.showAlert("Error", error.localizedDescription)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Helpers
    private func showPicker(title: String,
                            options: [String],
                            onPick: @escaping (String) -> Void) {

        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            ac.addAction(UIAlertAction(title: option, style: .default) { _ in
                onPick(option)
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    private func showAlert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
