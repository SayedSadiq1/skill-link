//
//  PaymentMethodViewController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//
import UIKit

class PaymentMethodViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    struct PaymentMethod {
        let name: String
        let imageName: String
        let destination: String
    }

    private let paymentMethods: [PaymentMethod] = [
        PaymentMethod(name: "Cash",       imageName: "cash",       destination: "rate"),
        PaymentMethod(name: "Visa - 1231",       imageName: "visa",       destination: "success"),
        PaymentMethod(name: "BenefitPay", imageName: "benefitpay", destination: "success"),
        PaymentMethod(name: "Add Card", imageName: "new_card", destination: "addCard")
    ]

    @IBOutlet weak var paymentMethodTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        paymentMethodTable.delegate = self
        paymentMethodTable.dataSource = self

        // Optional UI polish (recommended)
        paymentMethodTable.separatorStyle = .none
        paymentMethodTable.backgroundColor = .clear
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell",
                                                 for: indexPath) as! PaymentMethodCell

        let method = paymentMethods[indexPath.row]
        cell.configure(name: method.name, imageName: method.imageName, destination: method.destination)

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let method = paymentMethods[indexPath.row]

        
        switch method.destination {
            case "confirm":
                performSegue(withIdentifier: "confirmPayment", sender: self)
            case "addCard":
                performSegue(withIdentifier: "addCard", sender: self)
        default:
            break
        }
    }

}
