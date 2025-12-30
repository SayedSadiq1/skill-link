//
//  ServiceDetailsViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import UIKit

class ServiceDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var service: Service2!
    
    // MARK: - Cell Identifiers
    private enum CellIdentifier: String {
        case header = "headerCell"
        case provider = "providerCell"
        case description = "descriptionCell"
        case details = "detailsCell"
        case disclaimer = "disclaimerCell"
        case additionalInfo = "additionalInfoCell"
    }
    
    // MARK: - Sections Enum
    private enum Section: Int, CaseIterable {
        case header, provider, description, details, disclaimers, additionalInfo
        
        var title: String? {
            switch self {
            case .disclaimers: return "Disclaimers"
            case .additionalInfo: return "Additional Information"
            default: return nil
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMockService()
    }
    
    // MARK: - Mock Data
    private func loadMockService() {
        let mockProvider = UserProfile(
            name: "Modeer",
            skills: ["Electrician", "Stock Analyst"],
            brief: "Microsoft Certified Electrician!",
            contact: "+973 3232 4545"
        )
        
        service = Service2(
            id: UUID(),
            title: "Light Replacement Service",
            description: "Professional light replacement service for all types of fixtures. Our certified electricians ensure safe installation and optimal lighting solutions for your home or office.",
            category: "Electrical",
            priceBD: 13.0,
            priceType: .fixed,
            rating: 4.8,
            provider: mockProvider,
            available: true,
            disclaimers: [
                "Price includes labor only. Materials may incur additional charges.",
                "Service may be rescheduled due to weather conditions.",
                "24-hour cancellation policy applies."
            ],
            durationMinHours: 1,
            durationMaxHours: 1.5
        )
    }
}

// MARK: - UITableViewDataSource
extension ServiceDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .header, .provider, .description, .details:
            return 1 // One cell each
        case .disclaimers:
            return service.disclaimers.count // Dynamic based on disclaimers
        case .additionalInfo:
            return 1 // Or more if you have additional info array
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.header.rawValue, for: indexPath) as! ServiceDetailsHeaderCell
            configureHeaderCell(cell)
            return cell
            
        case .provider:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.provider.rawValue, for: indexPath) as! ServiceDetailsProviderCell
            configureProviderCell(cell)
            return cell
            
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.description.rawValue, for: indexPath) as! ServiceDetailsDescriptionCell
            configureDescriptionCell(cell)
            return cell
            
        case .details:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.details.rawValue, for: indexPath) as! ServiceDetailsDetailsCell
            configureDetailsCell(cell)
            return cell
            
        case .disclaimers:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.disclaimer.rawValue, for: indexPath) as! ServiceDetailsDisclaimerCell
            configureDisclaimerCell(cell, at: indexPath.row)
            return cell
            
        case .additionalInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.additionalInfo.rawValue, for: indexPath) as! ServiceDetailsExtraInfoCell
            configureAdditionalInfoCell(cell)
            return cell
        }
    }
    
    // MARK: - Cell Configuration Methods
    private func configureHeaderCell(_ cell: ServiceDetailsHeaderCell) {
        cell.titleLabel.text = service.title
        cell.categoryLabel.text = service.category
        cell.reviewsLabel.text = String(format: "%.1f", service.rating)
        cell.setStarsPrecise(rating: service.rating)
    }
    
    private func configureProviderCell(_ cell: ServiceDetailsProviderCell) {
        cell.providerName.text = service.provider.name
        cell.providerContactLabel.text = service.provider.contact
    }
    
    private func configureDescriptionCell(_ cell: ServiceDetailsDescriptionCell) {
        cell.descriptionLabel.text = service.description
    }
    
    private func configureDetailsCell(_ cell: ServiceDetailsDetailsCell) {
        // Format price
        let priceText = String(format: "%.2f BD", service.priceBD)
        let priceTypeText = service.priceType == .fixed ? "(Fixed Price)" : "(Per Hour)"
        cell.priceLabel.text = "\(priceText) \(priceTypeText)"
        
        // Availability
        cell.availabilityLabel.text = service.available ? "Available For Booking" : "Currently Unavailable"
        cell.availabilityLabel.textColor = service.available ? .systemTeal : .systemRed
        // Duration
        cell.durationLabel.text = "\(service.durationMinHours)-\(service.durationMaxHours) Hours"
    }
    
    private func configureDisclaimerCell(_ cell: ServiceDetailsDisclaimerCell, at index: Int) {
        guard index < service.disclaimers.count else { return }
        cell.disclaimerTextLabel.text = "\(service.disclaimers[index])"
    }
    
    private func configureAdditionalInfoCell(_ cell: ServiceDetailsExtraInfoCell) {
        cell.infoLabel.text = "For bookings or inquiries, please contact the provider directly. All payments are secured and processed through our platform."
    }
}

// MARK: - UITableViewDelegate
extension ServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }
        
        switch section {
        case .header:
            return 100
        case .provider:
            return 100
        case .description:
            return UITableView.automaticDimension // Let content determine
        case .details:
            return 135
        case .disclaimers:
            return UITableView.automaticDimension
        case .additionalInfo:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return 100
        }
        
        switch section {
        case .header:
            return 180
        case .provider:
            return 120
        case .description:
            return 200
        case .details:
            return 100
        case .disclaimers:
            return 60
        case .additionalInfo:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section(rawValue: section)?.title != nil ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // For dynamic height cells
        cell.layoutIfNeeded()
    }
}
