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

    private var servicePrice: Double = 0.0
    private var totalPrice: Double = 0.0
    private var isProcessingPayment = false

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // reset in case user comes back here
        isProcessingPayment = false
        paymentButton.isEnabled = true
    }

    @IBAction func paymentTapped(_ sender: UIButton) {

        guard !isProcessingPayment else { return }
        isProcessingPayment = true

        guard let serviceID = serviceID, !serviceID.isEmpty else {
            isProcessingPayment = false
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

                try await TransactionsController.shared.createTransaction(
                    id: Auth.auth().currentUser?.uid ?? "",
                    transaction: tx
                )

                replaceWithSeekerHome()

            } catch {
                isProcessingPayment = false
                paymentButton.isEnabled = true
                showSimpleAlert("Failed: \(error.localizedDescription)")
            }
        }
    }

    private func showSimpleAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func replaceWithSeekerHome() {
        guard let nav = navigationController else { return }

        let sb = UIStoryboard(name: "HomePage", bundle: nil)

        let homeVC = sb.instantiateViewController(withIdentifier: "SeekerHomeViewController")

        nav.setViewControllers([homeVC], animated: true)
    }
}
