//
//  SeekerHomeViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

final class SeekerHomeViewController: BaseViewController {

    override var shouldShowBackButton: Bool { false }

    @IBOutlet weak var recommendedTableView: UITableView!
    @IBOutlet weak var nextBookingTableView: UITableView!

    private let serviceManager = ServiceManager()
    private let db = Firestore.firestore()

    private var recommendedServices: [Service] = []

    private struct NextBookingUI {
        let status: String
        let date: Date
        let time: String
        let totalPrice: Double
        let serviceId: String
    }

    private var nextBookingUI: NextBookingUI?
    private var nextBookingService: Service?

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecommendedTable()
        setupNextBookingTable()
        fetchRecommended()
        fetchNextBooking()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecommended()
        fetchNextBooking()
    }

    // ✅ TRIGGER MANUAL SEGUE
    @IBAction func searchTapped(_ sender: Any) {
        // Ensure "toSearchServices" is the ID of the line coming from the yellow icon
        performSegue(withIdentifier: "toSearchServices", sender: self)
    }

    // MARK: - Next Booking

    private func setupNextBookingTable() {
        nextBookingTableView.dataSource = self
        nextBookingTableView.delegate = self
        nextBookingTableView.separatorStyle = .none
        nextBookingTableView.tableFooterView = UIView()
        nextBookingTableView.rowHeight = 90
        nextBookingTableView.estimatedRowHeight = 90
    }

    private func fetchNextBooking() {
        guard let userId = Auth.auth().currentUser?.uid else {
            nextBookingUI = nil
            nextBookingService = nil
            DispatchQueue.main.async { self.nextBookingTableView.reloadData() }
            return
        }

        let nowTs = Timestamp(date: Date())

        db.collection("Booking")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: nowTs)
            .order(by: "date", descending: false)
            .limit(to: 10)
            .getDocuments { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("Next booking fetch error:", error)
                    DispatchQueue.main.async {
                        self.nextBookingUI = nil
                        self.nextBookingService = nil
                        self.nextBookingTableView.reloadData()
                    }
                    return
                }

                let docs = snap?.documents ?? []
                var picked: NextBookingUI?

                for doc in docs {
                    let d = doc.data()
                    let status = d["status"] as? String ?? "Pending"
                    if status == "Canceled" || status == "Completed" { continue }

                    guard let ts = d["date"] as? Timestamp else { continue }
                    let date = ts.dateValue()

                    let serviceId = d["serviceId"] as? String ?? ""
                    if serviceId.isEmpty { continue }

                    let time = d["time"] as? String ?? ""
                    let totalPrice = Self.doubleValue(d["totalPrice"])

                    picked = NextBookingUI(
                        status: status,
                        date: date,
                        time: time,
                        totalPrice: totalPrice,
                        serviceId: serviceId
                    )
                    break
                }

                self.nextBookingUI = picked
                self.nextBookingService = nil

                guard let picked else {
                    DispatchQueue.main.async { self.nextBookingTableView.reloadData() }
                    return
                }

                self.serviceManager.fetchService(by: picked.serviceId) { [weak self] result in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let service):
                            self.nextBookingService = service
                        case .failure(let err):
                            print("Fetch service for next booking failed:", err)
                            self.nextBookingService = nil
                        }
                        self.nextBookingTableView.reloadData()
                    }
                }
            }
    }

    private func openServiceDetails(_ service: Service) {
        guard let nav = navigationController else { return }
        let sb = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "serviceDetailsPage") as? ServiceDetailsViewController {
            vc.service = service
            vc.navigationItem.title = "Service Details"
            nav.pushViewController(vc, animated: true)
        }
    }

    private static func doubleValue(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let s = any as? String, let d = Double(s) { return d }
        return 0
    }

    // MARK: - Recommended

    private func setupRecommendedTable() {
        recommendedTableView.dataSource = self
        recommendedTableView.delegate = self
        recommendedTableView.separatorStyle = .none
        recommendedTableView.tableFooterView = UIView()
        recommendedTableView.rowHeight = 110
        recommendedTableView.estimatedRowHeight = 110
    }

    private func fetchRecommended() {
        serviceManager.fetchAllServices { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let allServices):
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

    // MARK: - Navigation Actions

    @IBAction func messagesTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "ChatListView")
        nav.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(nav, animated: true)
    }

    @IBAction func bookingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "BookingsOverview", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "bookingsTabView")
        nav.navigationItem.title = "Bookings Overview"
        nav.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(nav, animated: true)
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

    @IBAction func recentlyviewedTapped(_ sender: Any) {
        recentlyViewedTapped(sender)
    }
}

extension SeekerHomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === nextBookingTableView { return 1 }
        if tableView === recommendedTableView { return recommendedServices.count }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === nextBookingTableView { return 90 }
        if tableView === recommendedTableView { return 110 }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView === nextBookingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextBookingCellTableViewCell", for: indexPath) as! NextBookingCellTableViewCell
            cell.selectionStyle = .none

            if let b = nextBookingUI {
                let dateText = dateFormatter.string(from: b.date)
                let subtitle = "\(dateText) • \(b.time) • \(Int(b.totalPrice)) BD"

                cell.configureBooking(status: b.status, subtitle: subtitle) { [weak self] in
                    guard let self, let service = self.nextBookingService else { return }
                    self.openServiceDetails(service)
                }
            } else {
                cell.configureNoBooking()
            }
            return cell
        }

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

        cell.serviceData = s
        cell.parent = self
        cell.selectionStyle = .none
        return cell
    }
}
