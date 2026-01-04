//
//  PaymentMethodViewController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//
import UIKit
import FirebaseAuth
class PaymentMethodViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var isCashOnDelivery: Bool = false
    var price: Double?
    var serviceID: String?
    private var paymentMethods: [PaymentMethod] = [
        PaymentMethod(name: "Cash", imageName: "cash", destination: "confirmOrder"),
        PaymentMethod(name: "BenefitPay", imageName: "benefitpay", destination:"confirmPayment"),
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
        
        Task{
            try await loadData()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isCashOnDelivery = false
        
        
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
            case "confirmPayment":
                performSegue(withIdentifier: "ConfirmPayment", sender: self)
            case "addCard":
                performSegue(withIdentifier: "addCard", sender: self)
            case "confirmOrder":
            isCashOnDelivery = true
            performSegue(withIdentifier: "ConfirmPayment", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmPayment" {
            if let destinationVC = segue.destination as? PaymentViewController {
                destinationVC.price = price
                destinationVC.serviceID = serviceID
                destinationVC.isCashOnDelivery = isCashOnDelivery
            }
        }
        else if segue.identifier == "addCard" {
            if let vc = segue.destination as? NewCardViewController {
                vc.price = price
                vc.serviceID = serviceID
            }
        }
    }
    
    func loadData() async throws{
        do{
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let userCards = try await PaymentController.shared.getPaymentMethods(id: uid)
                paymentMethods += userCards
                paymentMethodTable.reloadData()
            }catch{
                print("DEBUG: Error loading Cards: \(error)")
            }
        }
    }


