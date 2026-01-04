//
//  PaymentViewController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//

import UIKit
import FirebaseAuth

final class PaymentViewController: BaseViewController {

    @IBOutlet weak var totalContainer: UIStackView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var taxlabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!

    var serviceID: String?
    var price: Double?
    var isCashOnDelivery: Bool = false
    var tax: Double = 10.0
    var servicePrice: Double = 0.0
    var totalPrice: Double = 0.0
    var transaction: Transaction?

    private let serviceManager = ServiceFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()

        addTopBorder(to: totalContainer, color: UIColor(hex:"#E8DEF8"), height: 3)
        paymentButton.setTitle(isCashOnDelivery ? "Confirm" : "Pay Now", for: .normal)

        servicePrice = price ?? 0.0
        totalPrice = servicePrice + tax

        priceLabel.text = String(format: "%.2f BD", servicePrice)
        taxlabel.text = String(format: "%.2f BD", tax)
        totalLabel.text = String(format: "%.2f BD", totalPrice)
    }

    @IBAction func paymentTapped(_ sender: Any) {
        guard let serviceID = serviceID else {
            showSimpleAlert("Missing Service ID")
            return
        }

        paymentButton.isEnabled = false

        Task { @MainActor in
            do {
             
                let serviceTitle = try await serviceManager.getServiceTitle(serviceId: serviceID)

                let tx = Transaction(
                    id: nil,
                    amount: totalPrice,
                    serviceName: serviceTitle,
                    method: isCashOnDelivery ? "Cash" : "Card",
                    createdAt: Date()
                )

                self.transaction = tx

                try await TransactionsController.shared.createTransaction(id: Auth.auth().currentUser?.uid ?? "", transaction: tx)

                self.paymentButton.isEnabled = true
                self.showSimpleAlert("Transaction created ✅")
                self.popBack(steps: 3)

            } catch {
                self.paymentButton.isEnabled = true
                self.showSimpleAlert("Failed: \(error.localizedDescription)")
            }
        }
    }

    private func showSimpleAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
import UIKit

extension UIViewController {
    func popBack(steps: Int, animated: Bool = true) {
        guard let nav = navigationController else { return }

        let vcs = nav.viewControllers
        let targetIndex = vcs.count - 1 - steps

        guard targetIndex >= 0 else {
            nav.popToRootViewController(animated: animated)
            return
        }

        nav.popToViewController(vcs[targetIndex], animated: animated)
    }
}



