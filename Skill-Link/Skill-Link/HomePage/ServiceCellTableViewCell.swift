//
//  ServiceCellTableViewCell.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit

class ServiceCellTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    var serviceData: Service?
    weak var parent: UIViewController?

    @IBAction func viewDetailsClick(_ sender: Any) {
        guard let service = serviceData else { return }

        // ✅ safest navigation (works even if parent not set)
        let host = parent ?? parentViewController
        guard let nav = host?.navigationController else { return }

        let sb = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "serviceDetailsPage") as? ServiceDetailsViewController {
            vc.service = service
            vc.navigationItem.title = "Service Details"
            nav.pushViewController(vc, animated: true)
        }
    }
}

// ✅ helper to find the owning VC
private extension UIView {
    var parentViewController: UIViewController? {
        var r: UIResponder? = self
        while let next = r?.next {
            if let vc = next as? UIViewController { return vc }
            r = next
        }
        return nil
    }
}
