//
//  AddServiceViewController.swift
//  Skill-Link
//
//  Created by BP-36-212-20 on 03/01/2026.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

private struct AddServiceForm {
    var title: String = ""
    var description: String = ""
    var category: String?
    var availability: String?

    var priceType: PriceType = .Hourly
    var priceBD: Double?

    var minDuration: Double?
    var maxDuration: Double?

    var disclaimersText: String = ""   // newline-separated
}

final class AddServiceViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var form = AddServiceForm()

    private var categories: [String] = []
    private let availabilityOptions = ["Morning", "Afternoon", "Evening", "Night"]
    private let priceTypeOptions: [PriceType] = [.Fixed, .Hourly]

    private enum Row: Int, CaseIterable {
        case title, description, category, availability, priceType, price, minDuration, maxDuration, disclaimers, submit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // ✅ DO NOT set title (you’ll add header title yourself)
        setupTable()
        fetchCategories()
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }

    private func fetchCategories() {
        db.collection("metadata")
            .document("service_categories")
            .getDocument { [weak self] snap, _ in
                self?.categories = snap?.data()?["categories"] as? [String] ?? []
            }
    }

    private func submitService() {
        guard
            let uid = Auth.auth().currentUser?.uid,
            !form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let category = form.category,
            let availability = form.availability,
            let price = form.priceBD,
            let min = form.minDuration,
            let max = form.maxDuration
        else {
            showAlert("Missing Info", "Please fill all required fields.")
            return
        }

        let disclaimersArray: [String] = form.disclaimersText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let data: [String: Any] = [
            "title": form.title,
            "description": form.description,
            "category": category,
            "available": true,
            "availableAt": availability,
            "priceBD": price,
            "priceType": form.priceType.rawValue,
            "durationMinHours": min,
            "durationMaxHours": max,
            "disclaimers": disclaimersArray,
            "providerId": uid,
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

    private func showPicker(title: String, options: [String], onPick: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            ac.addAction(UIAlertAction(title: option, style: .default) { _ in onPick(option) })
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

extension AddServiceViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = Row(rawValue: indexPath.row)!

        switch row {

        case .title:
            return TextFieldCell.make(title: "Service Name", value: form.title) {
                self.form.title = $0
            }

        case .description:
            return TextViewCell.make(title: "Description", value: form.description, minHeight: 90) {
                self.form.description = $0
            }

        case .category:
            return ValueCell.make(title: "Category", value: form.category ?? "Choose")

        case .availability:
            return ValueCell.make(title: "Availability", value: form.availability ?? "Choose")

        case .priceType:
            return ValueCell.make(title: "Pricing Type", value: form.priceType.rawValue)

        case .price:
            let label = (form.priceType == .Hourly) ? "Price per Hour" : "Fixed Price"
            return NumberCell.make(title: label, value: form.priceBD) {
                self.form.priceBD = $0
            }

        case .minDuration:
            return NumberCell.make(title: "Min Duration (hrs)", value: form.minDuration) {
                self.form.minDuration = $0
            }

        case .maxDuration:
            return NumberCell.make(title: "Max Duration (hrs)", value: form.maxDuration) {
                self.form.maxDuration = $0
            }

        case .disclaimers:
            return TextViewCell.make(
                title: "Disclaimers (one per line)",
                value: form.disclaimersText,
                minHeight: 120
            ) {
                self.form.disclaimersText = $0
            }

        case .submit:
            return SubmitCell.make(title: "Add Service")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Row(rawValue: indexPath.row)!

        switch row {

        case .category:
            showPicker(title: "Category", options: categories) {
                self.form.category = $0
                tableView.reloadRows(at: [indexPath], with: .none)
            }

        case .availability:
            showPicker(title: "Availability", options: availabilityOptions) {
                self.form.availability = $0
                tableView.reloadRows(at: [indexPath], with: .none)
            }

        case .priceType:
            let options = priceTypeOptions.map { $0.rawValue }
            showPicker(title: "Pricing Type", options: options) { picked in
                if let matched = PriceType(rawValue: picked) {
                    self.form.priceType = matched
                    tableView.reloadRows(
                        at: [
                            IndexPath(row: Row.priceType.rawValue, section: 0),
                            IndexPath(row: Row.price.rawValue, section: 0)
                        ],
                        with: .none
                    )
                }
            }

        case .submit:
            submitService()

        default:
            break
        }
    }
}

// MARK: - Cells

final class TextFieldCell: UITableViewCell {
    static func make(title: String, value: String, onChange: @escaping (String) -> Void) -> UITableViewCell {
        let cell = TextFieldCell()
        cell.selectionStyle = .none

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)

        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.text = value
        tf.addAction(UIAction { _ in onChange(tf.text ?? "") }, for: .editingChanged)

        let stack = UIStackView(arrangedSubviews: [label, tf])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12)
        ])
        return cell
    }
}

// ✅ FIXED: delegate is retained INSIDE the cell (not a temporary wrapper)
final class TextViewCell: UITableViewCell, UITextViewDelegate {

    private let label = UILabel()
    private let tv = UITextView()
    private var onChange: ((String) -> Void)?
    private var heightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        label.font = .systemFont(ofSize: 14, weight: .medium)

        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.font = .systemFont(ofSize: 15)
        tv.delegate = self

        let stack = UIStackView(arrangedSubviews: [label, tv])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        heightConstraint = tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        heightConstraint?.isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    static func make(title: String, value: String, minHeight: CGFloat, onChange: @escaping (String) -> Void) -> UITableViewCell {
        let cell = TextViewCell()
        cell.label.text = title
        cell.tv.text = value
        cell.onChange = onChange
        cell.heightConstraint?.constant = minHeight
        return cell
    }

    func textViewDidChange(_ textView: UITextView) {
        onChange?(textView.text)
    }
}

final class ValueCell: UITableViewCell {
    static func make(title: String, value: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

final class NumberCell: UITableViewCell {
    static func make(title: String, value: Double?, onChange: @escaping (Double?) -> Void) -> UITableViewCell {
        let cell = NumberCell()
        cell.selectionStyle = .none

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)

        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.text = value != nil ? String(value!) : ""
        tf.addAction(UIAction { _ in onChange(Double(tf.text ?? "")) }, for: .editingChanged)

        let stack = UIStackView(arrangedSubviews: [label, tf])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12)
        ])
        return cell
    }
}

final class SubmitCell: UITableViewCell {
    static func make(title: String) -> UITableViewCell {
        let cell = SubmitCell()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        return cell
    }
}
