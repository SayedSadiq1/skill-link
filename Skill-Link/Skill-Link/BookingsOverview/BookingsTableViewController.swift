import UIKit

final class BookingsOverviewTableViewController: BaseViewController,
                                                 UITableViewDataSource,
                                                 UITableViewDelegate {

    @IBOutlet weak var table: UITableView!

    private var data: [Booking] = []
    private var filteredData: [Booking] = []
    private var currentState: BookedServiceStatus = .Upcoming

    private let bookingManager = BookingManager()
    private let serviceManager = ServiceManager()
    private let userService = FirebaseService.shared

    private let userId: String = LoginPageController.loggedinUser?.id ?? ""
    private let isProvider: Bool = LoginPageController.loggedinUser?.isProvider ?? false

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self

        setupForCurrentTab()
        fetchBookings()
    }

    private func fetchBookings() {
        guard !userId.isEmpty else { return }

        let handler: (Result<[Booking], Error>) -> Void = { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let bookings):
                self.data = bookings
                self.filteredData = bookings.filter { $0.status == self.currentState }
                self.table.reloadData()
            case .failure(let err):
                print("Next booking fetch error:", err.localizedDescription)
            }
        }

        if isProvider {
            bookingManager.fetchBookingsForProvider(userId, completion: handler)
        } else {
            bookingManager.fetchBookingsForUser(userId, completion: handler)
        }
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingsTableViewCell else {
            return UITableViewCell()
        }

        let booking = filteredData[indexPath.row]

        // ✅ IMPORTANT: set this BEFORE calling setupContextMenu
        cell.serviceId = booking.serviceId

        // ✅ When user taps Rate from menu, pass sender = serviceId
        cell.onRateTapped = { [weak self] serviceId in
            guard let self else { return }
            guard !serviceId.isEmpty else {
                print("❌ serviceId empty from cell")
                return
            }
            self.performSegue(withIdentifier: "toRate", sender: serviceId)
        }

        // UI
        cell.price.text = "\(booking.totalPrice) BD"
        cell.time.text = booking.time
        cell.location.text = booking.location

        let df = DateFormatter()
        df.dateStyle = .medium
        cell.date.text = df.string(from: booking.date)

        serviceManager.fetchService(by: booking.serviceId) { [weak cell] result in
            if case .success(let service) = result {
                cell?.serviceTitle.text = service.title
            }
        }

        userService.fetchUserProfile(uid: isProvider ? booking.userId : booking.providerId) { [weak self, weak cell] result in
            guard let self, let cell else { return }
            if case .success(let user) = result {
                cell.providedBy.text = self.isProvider
                    ? "Booked By: \(user.fullName)"
                    : "Provided By: \(user.fullName)"
            }
        }

        cell.setupContextMenu(state: currentState)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let booking = filteredData[indexPath.row]
        guard booking.status == .Completed else { return }

        // ✅ pass sender directly
        performSegue(withIdentifier: "toRate", sender: booking.serviceId)
    }

    // MARK: - Tabs
    private func setupForCurrentTab() {
        guard let index = tabBarController?.viewControllers?.firstIndex(of: self) else { return }

        if isProvider {
            switch index {
            case 0: currentState = .Pending
            case 1: currentState = .Upcoming
            case 2: currentState = .Completed
            case 3: currentState = .Canceled
            default: currentState = .Upcoming
            }
        } else {
            switch index {
            case 0: currentState = .Upcoming
            case 1: currentState = .Completed
            case 2: currentState = .Canceled
            default: currentState = .Upcoming
            }
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toRate" else { return }

        guard let serviceId = sender as? String, !serviceId.isEmpty else {
            print("❌ sender serviceId missing in prepare | sender:", String(describing: sender))
            return
        }

        let dest = (segue.destination as? UINavigationController)?.viewControllers.first ?? segue.destination

        guard let rateVC = dest as? RateFormController else {
            print("❌ Destination is not RateFormController:", type(of: dest))
            return
        }

        rateVC.serviceID = serviceId
        print("✅ Passing serviceID:", serviceId)
    }
}
