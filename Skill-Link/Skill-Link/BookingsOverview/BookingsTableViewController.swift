import UIKit

final class BookingsOverviewTableViewController: BaseViewController,
                                                 UITableViewDataSource,
                                                 UITableViewDelegate,
                                                 BookingsTableViewCellDelegate {

    @IBOutlet weak var table: UITableView!

    private var data: [Booking] = []
    private var filteredData: [Booking] = []
    private var currentState: BookedServiceStatus = .Upcoming

    private var isProvider: Bool = LoginPageController.loggedinUser?.isProvider ?? false

    private let bookingManager = BookingManager()
    private let serviceManager = ServiceManager()
    private let userService = FirebaseService.shared

    private let userId: String = LoginPageController.loggedinUser?.id ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        

        table.dataSource = self
        table.delegate = self

        addProviderView()
        setupForCurrentTab()
        fetchBookings()
    }

    private func fetchBookings() {
        guard !userId.isEmpty else {
            print("❌ No logged-in userId")
            return
        }

        if isProvider {
            bookingManager.fetchBookingsForProvider(userId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let bookings):
                    self.data = bookings
                    self.filteredData = bookings.filter { $0.status == self.currentState }
                    self.table.reloadData()
                    self.refreshTabs()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            bookingManager.fetchBookingsForUser(userId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let bookings):
                    self.data = bookings
                    self.filteredData = bookings.filter { $0.status == self.currentState }
                    self.table.reloadData()
                    self.refreshTabs()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func addProviderView() {
        guard isProvider else { return }
        guard let tabBarController = self.tabBarController else { return }

        // Avoid duplicates if already added
        if tabBarController.viewControllers?.contains(where: { $0.tabBarItem.title == "Pending" }) == true {
            return
        }

        let storyboard = UIStoryboard(name: "BookingsOverview", bundle: nil)
        let providerVC = storyboard.instantiateViewController(withIdentifier: "PendingBookings")
        providerVC.tabBarItem = UITabBarItem(
            title: "Pending",
            image: UIImage(systemName: "person.fill.checkmark.and.xmark"),
            tag: 0
        )

        var currentVCs = tabBarController.viewControllers ?? []
        currentVCs.insert(providerVC, at: 0)
        tabBarController.viewControllers = currentVCs
    }

    // MARK: - Delegate (Approve/Decline)
    func didTapApprove(for serviceId: String) {
        BookingDataManager.shared.updateBookingState(serviceId: serviceId, newState: .Upcoming)
        showAlert(message: "Booking approved successfully!")
        reloadForCurrentState()
    }

    func didTapDecline(for serviceId: String) {
        BookingDataManager.shared.updateBookingState(serviceId: serviceId, newState: .Canceled)
        showAlert(message: "Booking declined")
        reloadForCurrentState()
    }

    // MARK: - NEW Delegate actions (Completed menu)
    func didTapRate(for serviceId: String) {
        performSegue(withIdentifier: "toRate", sender: serviceId)
    }

    func didTapSeeDetails(for serviceId: String) {
        performSegue(withIdentifier: "toBookingDetails", sender: serviceId)
    }

    func didTapFavorite(for serviceId: String) {
        // put your favorite logic here
        showAlert(message: "Added to favorites")
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                       for: indexPath) as? BookingsTableViewCell else {
            return UITableViewCell()
        }

        let booking = filteredData[indexPath.row]

        // Delegate + serviceId for actions
        cell.delegate = self
        cell.serviceId = booking.serviceId

        // Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.date?.text = dateFormatter.string(from: booking.date)

        cell.time?.text = booking.time
        cell.location?.text = booking.location
        cell.price?.text = "\(booking.totalPrice)BD"

        // Service title async
        serviceManager.fetchService(by: booking.serviceId) { [weak cell] result in
            if case .success(let service) = result {
                cell?.serviceTitle.text = service.title
            }
        }

        // Provided by / Booked by async
        userService.fetchUserProfile(uid: isProvider ? booking.userId : booking.providerId) { [weak self, weak cell] (result: Result<UserProfile, Error>) in
            guard let self, let cell else { return }

            switch result {
            case .success(let user):
                if self.currentState == .Pending || self.isProvider {
                    cell.providedBy?.text = "Booked By: \(user.fullName)"
                } else {
                    cell.providedBy?.text = "Provided By: \(user.fullName)"
                }
            case .failure(let err):
                print("Failed to get user for cell: \(err.localizedDescription)")
            }
        }

        // Status UI
        if let stateLabel = cell.bookingCategory as? CardLabel {
            stateLabel.alpha = 0.65
            stateLabel.text = booking.status.rawValue

            switch booking.status {
            case .Pending:
                stateLabel.setBackgroundColor(.yellow)
            case .Upcoming:
                stateLabel.setBackgroundColor(.tintColor)
            case .Completed:
                stateLabel.setBackgroundColor(.systemGreen)
            case .Canceled:
                stateLabel.setBackgroundColor(.orange)
            }
        }

        // Context menu based on current tab
        cell.setupContextMenu(state: currentState)

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Tab filtering
    private func setupForCurrentTab() {
        guard let tabBarController = self.tabBarController,
              let index = tabBarController.viewControllers?.firstIndex(of: self) else { return }

        if !isProvider {
            switch index {
            case 0: currentState = .Upcoming
            case 1: currentState = .Completed
            case 2: currentState = .Canceled
            default: break
            }
        } else {
            switch index {
            case 0: currentState = .Pending
            case 1: currentState = .Upcoming
            case 2: currentState = .Completed
            case 3: currentState = .Canceled
            default: break
            }
        }

        // Use local data to filter (avoid mismatch with BookingDataManager)
        filteredData = data.filter { $0.status == currentState }
        table.reloadData()
    }

    private func reloadForCurrentState() {
        // Re-filter + reload
        filteredData = data.filter { $0.status == currentState }
        table.reloadData()
        refreshTabs()
    }

    private func refreshTabs() {
        guard let tabBarController = self.navigationController?.tabBarController else { return }

        tabBarController.viewControllers?.forEach { vc in
            if let nav = vc as? UINavigationController,
               let bookingVC = nav.viewControllers.first as? BookingsOverviewTableViewController,
               bookingVC != self {
                bookingVC.filteredData = bookingVC.data.filter { $0.status == bookingVC.currentState }
                bookingVC.table.reloadData()
            } else if let bookingVC = vc as? BookingsOverviewTableViewController,
                      bookingVC != self {
                bookingVC.filteredData = bookingVC.data.filter { $0.status == bookingVC.currentState }
                bookingVC.table.reloadData()
            }
        }
    }

    // MARK: - Segue payload
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRate",
           let serviceId = sender as? String,
           let vc = segue.destination as? RateFormController {
            vc.serviceID = serviceId
        }
    }
}
