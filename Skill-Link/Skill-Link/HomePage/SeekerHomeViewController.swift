//
//  SeekerHomeViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit
import FirebaseFirestore

final class SeekerHomeViewController: BaseViewController {

    override var shouldShowBackButton: Bool { false }

    // ✅ Connect this to your "Recommended Table View" in storyboard
    @IBOutlet weak var recommendedTableView: UITableView!

    private let serviceManager = ServiceManager()
    private var recommendedServices: [Service] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecommendedTable()
        fetchRecommended()

        // ✅ keep your existing setup/actions untouched
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecommended()
    }

    // MARK: - Recommended UI

    private func setupRecommendedTable() {
        recommendedTableView.dataSource = self
        recommendedTableView.delegate = self
        recommendedTableView.separatorStyle = .none
        recommendedTableView.tableFooterView = UIView()

        // ✅ Most important: fixes your cramped UI (screenshot issue)
        recommendedTableView.rowHeight = 110
        recommendedTableView.estimatedRowHeight = 110
    }

    private func fetchRecommended() {
        // ✅ simplest and safest: reuse your existing manager
        serviceManager.fetchAllServices { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let allServices):
                    // Recommended: available first, rating high -> low, show top 5
                    let top = allServices
                        .filter { $0.available }
                        .sorted { $0.rating > $1.rating }

                    self.recommendedServices = Array(top.prefix(5))
                    self.recommendedTableView.reloadData()

                case .failure(let error):
                    print("Recommended fetch error:", error)
                    self.recommendedServices = []
                    self.recommendedTableView.reloadData()
                }
            }
        }
    }

    // MARK: - Your existing navigation (UNCHANGED)

    @IBAction func messagesTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "ChatListView")
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(nav, animated: true)
    }

    @IBAction func bookingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "BookingsOverview", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "bookingsTabView")
        nav.navigationItem.title = "Bookings Overview"
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(nav, animated: true)
    }

    @IBAction func profileTapped(_ sender: Any) {
        let isProvider = LoginPageController.loggedinUser?.isProvider ?? false
        let storyboard = UIStoryboard(name: "login", bundle: nil)

        if isProvider {
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileProviderViewController")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileSeekerViewController")
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func settingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NotificationCenterViewController") as! NotificationCenterViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func favoriteTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Favorite", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func recentlyViewedTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Favorite", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RecentlyViewedViewController") as! RecentlyViewedViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    // ✅ prevents crash if storyboard still wired to old action name
    @IBAction func recentlyviewedTapped(_ sender: Any) {
        recentlyViewedTapped(sender)
    }
}

// MARK: - Table

extension SeekerHomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === recommendedTableView { return recommendedServices.count }
        return 0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === recommendedTableView { return 110 } // ✅ fixed sizing
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // ✅ storyboard reuse identifier for your prototype cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCellTableViewCell

        let s = recommendedServices[indexPath.row]

        cell.serviceNameLabel.text = s.title
        cell.priceLabel.text = "\(Int(s.priceBD)) BD"
        cell.ratingLabel.text = String(format: "%.1f", s.rating)

        if s.available {
            cell.availabilityLabel.text = "Available \(s.availableAt)"
            cell.availabilityLabel.textColor = .systemGreen
            cell.checkmarkImage?.image = UIImage(systemName: "checkmark.circle.fill")
            cell.checkmarkImage?.tintColor = .systemGreen
        } else {
            cell.availabilityLabel.text = "Unavailable"
            cell.availabilityLabel.textColor = .systemRed
            cell.checkmarkImage?.image = UIImage(systemName: "xmark.circle.fill")
            cell.checkmarkImage?.tintColor = .systemRed
        }

        // ✅ critical: ensures View Details goes to the SAME service
        cell.serviceData = s
        cell.parent = self

        cell.selectionStyle = .none
        return cell
    }
}
