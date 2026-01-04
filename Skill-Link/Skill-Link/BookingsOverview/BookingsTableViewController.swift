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

    private let userId = LoginPageController.loggedinUser?.id ?? ""
    private let isProvider = LoginPageController.loggedinUser?.isProvider ?? false

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self

        setupForCurrentTab()
        fetchBookings()
    }

    // MARK: - Fetch
    private func fetchBookings() {
        guard !userId.isEmpty else { return }

        let handler: (Result<[Booking], Error>) -> Void = { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let bookings):
                self.data = bookings
                self.filteredData = bookings.filter { $0.status == self.currentState }
                self.table.reloadData()
            case .failure(let error):
                print("❌ Fetch bookings error:", error.localizedDescription)
            }
        }

        isProvider
            ? bookingManager.fetchBookingsForProvider(userId, completion: handler)
            : bookingManager.fetchBookingsForUser(userId, completion: handler)
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                as? BookingsTableViewCell else {
            return UITableViewCell()
        }

        let booking = filteredData[indexPath.row]

        cell.serviceId = booking.serviceId

        cell.onRateTapped = { [weak self] serviceId in
            guard let self, !serviceId.isEmpty else { return }
            self.performSegue(withIdentifier: "toRate", sender: serviceId)
        }

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

        userService.fetchUserProfile(uid: isProvider ? booking.userId : booking.providerId) {
            [weak cell] result in
            if case .success(let user) = result {
                cell?.providedBy.text = self.isProvider
                    ? "Booked By: \(user.fullName)"
                    : "Provided By: \(user.fullName)"
            }
        }

        cell.setupContextMenu(state: currentState)
        return cell
    }

    // MARK: - Tabs
    private func setupForCurrentTab() {
        guard let index = tabBarController?.viewControllers?.firstIndex(of: self) else { return }

        if isProvider {
            currentState = [.Pending, .Upcoming, .Completed, .Canceled][safe: index] ?? .Upcoming
        } else {
            currentState = [.Upcoming, .Completed, .Canceled][safe: index] ?? .Upcoming
        }
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toRate",
              let serviceId = sender as? String,
              !serviceId.isEmpty else { return }

        let dest = (segue.destination as? UINavigationController)?.viewControllers.first
            ?? segue.destination

        (dest as? RateFormController)?.serviceID = serviceId
    }
}
