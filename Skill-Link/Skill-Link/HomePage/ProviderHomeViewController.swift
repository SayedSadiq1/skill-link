//
//  ProviderHomeViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
// ProviderHomeViewController.swift
// ProviderHomeViewController.swift
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProviderHomeViewController: BaseViewController {

    override var shouldShowBackButton: Bool { false }

    // MARK: - Outlets (CONNECT THESE ONLY)
    @IBOutlet weak var todayBookingTableView: UITableView!

    @IBOutlet weak var requestsTitleLabel: UILabel!
    @IBOutlet weak var requestsCountLabel: UILabel!
    @IBOutlet weak var requestsSubtitleLabel: UILabel!
    @IBOutlet weak var requestsChevronButton: UIButton!

    @IBOutlet weak var ratingValueLabel: UILabel!
    @IBOutlet weak var completedJobsValueLabel: UILabel!
    @IBOutlet weak var earningsValueLabel: UILabel!

    // MARK: - Firebase
    private let db = Firestore.firestore()
    private let serviceManager = ServiceManager()

    // MARK: - Empty label (CODE ONLY)
    private let noBookingsLabel: UILabel = {
        let l = UILabel()
        l.text = "No Bookings today"
        l.textAlignment = .center
        l.numberOfLines = 1
        l.font = .systemFont(ofSize: 20, weight: .regular)   // match storyboard style
        l.textColor = .label
        l.backgroundColor = .clear
        l.isHidden = true
        return l
    }()

    // MARK: - State
    private struct TodayBookingVM {
        let seekerId: String
        let seekerName: String
        let service: Service
        let timeText: String
        let priceText: String
    }

    private var todayBookingVM: TodayBookingVM?
    private var pendingCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Table setup
        todayBookingTableView.dataSource = self
        todayBookingTableView.delegate = self
        todayBookingTableView.tableFooterView = UIView()
        todayBookingTableView.separatorStyle = .none
        todayBookingTableView.rowHeight = 110
        todayBookingTableView.estimatedRowHeight = 110

        // Dashboard values readable (keep your storyboard layout)
        ratingValueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        completedJobsValueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        earningsValueLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        // Banner looks like storyboard (no "...")
        requestsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        requestsSubtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)

        requestsTitleLabel.numberOfLines = 1
        requestsTitleLabel.adjustsFontSizeToFitWidth = true
        requestsTitleLabel.minimumScaleFactor = 0.85

        requestsSubtitleLabel.numberOfLines = 1
        requestsSubtitleLabel.adjustsFontSizeToFitWidth = true
        requestsSubtitleLabel.minimumScaleFactor = 0.85

        // Chevron behavior
        requestsChevronButton?.addTarget(self, action: #selector(openBookingsOverview), for: .touchUpInside)

        // Add the empty label ON TOP OF the table area (correct placement)
        view.addSubview(noBookingsLabel)

        // Defaults
        setRequestsUI(count: 0)
        setDashboard(rating: 0, completed: 0, earnings: 0)
        showNoBookingUI(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ Place empty label centered inside the TodayBookingTableView area
        // so it NEVER overlaps the dashboard/banner.
        let frameInView = todayBookingTableView.convert(todayBookingTableView.bounds, to: view)

        // Make the label height small and centered
        let labelHeight: CGFloat = 28
        noBookingsLabel.frame = CGRect(
            x: frameInView.minX,
            y: frameInView.midY - (labelHeight / 2),
            width: frameInView.width,
            height: labelHeight
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProviderHome()
    }

    private func refreshProviderHome() {
        refreshDashboard()
        refreshTodayBookingAndRequests()
    }

    // MARK: - Dashboard

    private func refreshDashboard() {
        guard let providerId = Auth.auth().currentUser?.uid else { return }

        let group = DispatchGroup()

        var avgRating: Double = 0
        var completedCount: Int = 0
        var earningsTotal: Double = 0

        // Rating = average of provider services ratings
        group.enter()
        db.collection("Service")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snap, error in
                defer { group.leave() }
                if let error = error {
                    print("Dashboard rating fetch error:", error)
                    return
                }

                let ratings: [Double] = (snap?.documents ?? []).compactMap { doc in
                    let v = doc.data()["rating"]
                    if let d = v as? Double { return d }
                    if let i = v as? Int { return Double(i) }
                    if let s = v as? String, let d = Double(s) { return d }
                    return nil
                }

                avgRating = ratings.isEmpty ? 0 : (ratings.reduce(0, +) / Double(ratings.count))
            }

        // Completed jobs + earnings from completed bookings
        group.enter()
        db.collection("Booking")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snap, error in
                defer { group.leave() }
                if let error = error {
                    print("Dashboard bookings fetch error:", error)
                    return
                }

                let docs = snap?.documents ?? []
                let completedDocs = docs.filter {
                    let status = ($0.data()["status"] as? String ?? "").lowercased()
                    return status == "completed"
                }

                completedCount = completedDocs.count
                earningsTotal = completedDocs.reduce(0.0) { partial, doc in
                    partial + Self.doubleValue(doc.data()["totalPrice"])
                }
            }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.setDashboard(rating: avgRating, completed: completedCount, earnings: earningsTotal)
        }
    }

    private func setDashboard(rating: Double, completed: Int, earnings: Double) {
        ratingValueLabel.text = rating == 0 ? "-" : String(format: "%.1f", rating)
        completedJobsValueLabel.text = "\(completed)"
        earningsValueLabel.text = String(format: "%.1f BD", earnings)
    }

    // MARK: - Today Booking + Requests

    private func refreshTodayBookingAndRequests() {
        guard let providerId = Auth.auth().currentUser?.uid else { return }

        db.collection("Booking")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }

                if let error = error {
                    print("ProviderHome bookings fetch error:", error)
                    DispatchQueue.main.async {
                        self.pendingCount = 0
                        self.todayBookingVM = nil
                        self.setRequestsUI(count: 0)
                        self.showNoBookingUI(true)
                        self.todayBookingTableView.reloadData()
                    }
                    return
                }

                let docs = snap?.documents ?? []

                // Pending requests count
                let pending = docs.filter {
                    let status = ($0.data()["status"] as? String ?? "").lowercased()
                    return status == "pending"
                }
                self.pendingCount = pending.count

                DispatchQueue.main.async {
                    self.setRequestsUI(count: self.pendingCount)
                }

                // Today's booking: nearest today, not completed/canceled
                let cal = Calendar.current
                let now = Date()

                func bookingDate(_ doc: QueryDocumentSnapshot) -> Date? {
                    (doc.data()["date"] as? Timestamp)?.dateValue()
                }

                let candidates: [(doc: QueryDocumentSnapshot, date: Date)] = docs.compactMap { doc in
                    guard let d = bookingDate(doc) else { return nil }
                    let status = (doc.data()["status"] as? String ?? "").lowercased()
                    if status == "completed" || status == "canceled" || status == "cancelled" { return nil }
                    if !cal.isDate(d, inSameDayAs: now) { return nil }
                    return (doc, d)
                }

                guard let best = candidates.sorted(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) }).first else {
                    DispatchQueue.main.async {
                        self.todayBookingVM = nil
                        self.showNoBookingUI(true)
                        self.todayBookingTableView.reloadData()
                    }
                    return
                }

                let data = best.doc.data()
                let seekerId = data["userId"] as? String ?? ""
                let serviceId = data["serviceId"] as? String ?? ""

                let timeField = data["time"] as? String ?? ""
                let timeText = timeField.isEmpty ? best.date.formatted(date: .omitted, time: .shortened) : timeField

                let price = Self.doubleValue(data["totalPrice"])
                let priceText = price == 0 ? "-" : "\(Int(price)) BD"

                self.serviceManager.fetchService(by: serviceId) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let service):
                        self.fetchUserFullName(userId: seekerId) { [weak self] name in
                            guard let self = self else { return }
                            let seekerName = (name?.isEmpty == false) ? name! : "Customer"

                            DispatchQueue.main.async {
                                self.todayBookingVM = TodayBookingVM(
                                    seekerId: seekerId,
                                    seekerName: seekerName,
                                    service: service,
                                    timeText: timeText,
                                    priceText: priceText
                                )
                                self.showNoBookingUI(false)
                                self.todayBookingTableView.reloadData()
                            }
                        }

                    case .failure(let err):
                        print("ProviderHome fetch service failed:", err)
                        DispatchQueue.main.async {
                            self.todayBookingVM = nil
                            self.showNoBookingUI(true)
                            self.todayBookingTableView.reloadData()
                        }
                    }
                }
            }
    }

    private func showNoBookingUI(_ show: Bool) {
        noBookingsLabel.isHidden = !show
        todayBookingTableView.isHidden = show
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setRequestsUI(count: Int) {
        if count <= 0 {
            requestsTitleLabel.text = "No new booking requests"
            requestsCountLabel.text = ""
            requestsSubtitleLabel.text = "You're all caught up"
            requestsChevronButton.isHidden = true
        } else if count == 1 {
            requestsTitleLabel.text = "1 New Request Available"
            requestsCountLabel.text = ""
            requestsSubtitleLabel.text = "Tap To View"
            requestsChevronButton.isHidden = false
        } else {
            requestsTitleLabel.text = "\(count) New Requests Available"
            requestsCountLabel.text = ""
            requestsSubtitleLabel.text = "Tap To View"
            requestsChevronButton.isHidden = false
        }
    }

    private func fetchUserFullName(userId: String, completion: @escaping (String?) -> Void) {
        guard !userId.isEmpty else { completion(nil); return }
        db.collection("User").document(userId).getDocument { snap, _ in
            completion(snap?.data()?["fullName"] as? String)
        }
    }

    private static func doubleValue(_ any: Any?) -> Double {
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let s = any as? String, let d = Double(s) { return d }
        return 0
    }

    // MARK: - Actions used by cell

    private func openProviderServiceDetails(_ service: Service) {
        guard let nav = navigationController else { return }
        let sb = UIStoryboard(name: "ServiceDetailsStoryboard", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "serviceDetailsPage") as? ServiceDetailsViewController {
            vc.service = service
            vc.navigationItem.title = "Service Details"
            nav.pushViewController(vc, animated: true)
        }
    }

    private func openDirectChatWithSeeker(seekerId: String, seekerName: String) {
        guard let providerId = Auth.auth().currentUser?.uid else { return }
        guard !seekerId.isEmpty else { return }

        let pairId = [providerId, seekerId].sorted().joined(separator: "_")
        let chatRef = db.collection("Chats").document(pairId)

        chatRef.getDocument { [weak self] doc, _ in
            guard let self = self else { return }

            let openChat = {
                let sb = UIStoryboard(name: "Chat", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "ProviderChatViewController") as! ProviderChatViewController
                vc.chatId = pairId
                vc.chatTitle = seekerName
                self.navigationController?.pushViewController(vc, animated: true)
            }

            if doc?.exists == true {
                openChat()
                return
            }

            let providerName = LocalUserStore.loadProfile()?.fullName ?? "Provider"

            chatRef.setData([
                "participants": [providerId, seekerId],
                "pairId": pairId,
                "providerId": providerId,
                "providerName": providerName,
                "seekerId": seekerId,
                "seekerName": seekerName,
                "createdAt": Timestamp(),
                "lastMessage": "",
                "lastMessageTime": Timestamp(),
                "lastSenderId": ""
            ]) { _ in
                openChat()
            }
        }
    }

    @objc private func openBookingsOverview() {
        bookingsTapped(self)
    }

    // =======================================================
    // ✅ YOUR EXISTING NAVIGATION IBACTIONS (UNCHANGED)
    // =======================================================

    @IBAction func messagesTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Chat", bundle: nil)
        let nav = sb.instantiateViewController(withIdentifier: "ProviderChatListView")
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

    @IBAction func settingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "NotificationCenterViewController") as! NotificationCenterViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func profileTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProfileProviderViewController") as! ProfileProviderViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Table
extension ProviderHomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If no booking, table is hidden and rows = 0
        return (todayBookingVM == nil) ? 0 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TodayBookingCellTableViewCell",
            for: indexPath
        ) as! TodayBookingCellTableViewCell

        let vm = todayBookingVM!

        cell.configureBooking(
            seekerName: vm.seekerName,
            category: vm.service.category,
            timeText: vm.timeText,
            priceText: vm.priceText
        )

        cell.onViewDetails = { [weak self] in
            guard let self = self else { return }
            self.openProviderServiceDetails(vm.service)
        }

        cell.onChat = { [weak self] in
            guard let self = self else { return }
            self.openDirectChatWithSeeker(seekerId: vm.seekerId, seekerName: vm.seekerName)
        }

        return cell
    }
}
