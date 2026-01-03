import UIKit

class BookingsOverviewTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, BookingsTableViewCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    private var data: [Booking] = []
    private var filteredData: [Booking] = []
    private var currentState: BookedServiceStatus = .Upcoming
    private var isProvider = LoginPageController.loggedinUser?.isProvider ?? true
    private let bookingManager = BookingManager()
    private let serviceManager = ServiceManager()
    private let userService = FirebaseService.shared
    private let userId = LoginPageController.loggedinUser?.id ?? "07PX2EXm9EXdcwV1IhT3jJiFxO02"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
            table.dataSource = self
            
            // Add this notification observer
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleDataUpdate),
                name: .bookingDataDidChange,
                object: nil
            )
            
            // Initial load
            Task {
                await loadBookings()
            }
            
            addProviderView()
            setupForCurrentTab()
    }
    

    private func addProviderView() {
        if !(isProvider) {
            return
        }
        
        // 1. Get a reference to your Tab Bar Controller
        guard let tabBarController = self.tabBarController else {
            return
        }
        
        if tabBarController.viewControllers?.count == 4 {
            return
        }
        
        // 2. Prepare your conditional view controller (e.g., from Storyboard)
        let storyboard = UIStoryboard(name: "BookingsOverview", bundle: nil)
        let providerVC = storyboard.instantiateViewController(withIdentifier: "PendingBookings")
        
        // Configure the adminVC's tab bar item
        providerVC.tabBarItem = UITabBarItem(title: "Pending", image: UIImage(systemName: "person.fill.checkmark.and.xmark"), tag: 3)
        
        // 3. Check the condition (e.g., user is an admin)
        if isProvider {
            // Insert the admin tab as the fourth item (index 3)
            var currentViewControllers = tabBarController.viewControllers ?? []
            // Ensure we don't insert it multiple times
            if !currentViewControllers.contains(providerVC) {
                currentViewControllers.insert(providerVC, at: 0) // Add at specific position
                tabBarController.viewControllers = currentViewControllers
            }
        } else {
            if let providerVCIndex = tabBarController.viewControllers?.firstIndex(where: { $0.tabBarItem.title == "Pending" }) {
                var currentViewControllers = tabBarController.viewControllers
                currentViewControllers?.remove(at: providerVCIndex)
                tabBarController.viewControllers = currentViewControllers
            }
        }
    }
    
    func didTapApprove(for booking: Booking) {
        print("didTapApprove")
        booking.status = .Upcoming
        self.bookingManager.saveBooking(booking) { [weak self] result in
            switch result {
            case .success(_):
                self?.updateBookingState(serviceId: booking.serviceId, newState: .Upcoming)
                self?.table.reloadData()
                self?.refreshTabs()
            case .failure(let failure):
                self?.showAlert(message: "Action failed: \(failure.localizedDescription)")
            }
        }
        
        self.table.reloadData()
        self.refreshTabs()
        self.showAlert(message: "Booking approved successfully!")
    }
    
    func didTapDecline(for booking: Booking) {
        print("didTapDecline")
        booking.status = .Canceled
        self.bookingManager.saveBooking(booking) { [weak self] result in
            switch result {
            case .success(_):
                self?.updateBookingState(serviceId: booking.serviceId, newState: .Canceled)
                self?.table.reloadData()
                self?.refreshTabs()
            case .failure(let failure):
                self?.showAlert(message: "Action failed: \(failure.localizedDescription)")
            }
        }
        
        self.table.reloadData()
        self.refreshTabs()
        self.showAlert(message: "Booking declined")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingsTableViewCell else {
            return UITableViewCell()
        }
        
        let booking = filteredData[indexPath.row]  // Use filteredData
        
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        serviceManager.fetchService(by: booking.serviceId) { [weak cell] result in
            switch result {
            case .success(let service):
                cell?.serviceTitle.text = service.title
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
        print("Setting user label jksahdkjsahdkjsahdkjsahkjdhskadsad")
        userService.fetchUserProfile(uid: isProvider ? booking.userId : booking.providerId) {[weak cell, weak self] (result : Result<UserProfile, Error>) in
            switch result {
            case .success(let user):
                if self!.currentState == .Pending {
                    cell!.providedBy?.text = "Booked By: \(user.fullName)"
                } else {
                    if self!.isProvider {
                        cell!.providedBy?.text = "Booked By: \(user.fullName)"
                    } else {
                        cell!.providedBy?.text = "Provided By: \(user.fullName)"
                    }
                }
            case .failure(let failure):
                print("Failed to get user for cell: \(failure.localizedDescription)")
            }
        }
        
        cell.date?.text = dateFormatter.string(from: booking.date)
        cell.time?.text = booking.time
        cell.location?.text = booking.location
        cell.price?.text = "\(booking.totalPrice)BD"
        cell.booking = booking
        cell.delegate = self
        
        let stateLabel = cell.bookingCategory as! CardLabel
        stateLabel.alpha = CGFloat(0.65)
        stateLabel.text = booking.status.rawValue
        switch booking.status {
        case .Pending:
            stateLabel.setBackgroundColor(UIColor.yellow)
        case .Upcoming:
            stateLabel.setBackgroundColor(UIColor.tintColor)
        case .Completed:
            stateLabel.setBackgroundColor(UIColor.systemGreen)
        case .Canceled:
            stateLabel.setBackgroundColor(UIColor.orange)
        }
        
        cell.setupContextMenu(state: currentState)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        // Handle row selection
    }
    
    private func setupForCurrentTab() {
        // Get the current tab index
        if let tabBarController = self.tabBarController,
           let index = tabBarController.viewControllers?.firstIndex(of: self) {
            
            // Set current state based on tab index
            if !(isProvider) {
                switch index {
                case 0:
                    currentState = .Upcoming
                case 1:
                    currentState = .Completed
                case 2:
                    currentState = .Canceled
                default:
                    break
                }
            } else {
                switch index {
                case 0:
                    currentState = .Pending
                case 1:
                    currentState = .Upcoming
                case 2:
                    currentState = .Completed
                case 3:
                    currentState = .Canceled
                default:
                    break
                }
            }
            
            
            // Filter the data
            filteredData = BookingDataManager.shared.getBookings(for: currentState)
            
            // Reload table
            table.reloadData()
            
            // Debug
            print("Tab \(index): Showing \(filteredData.count) \(currentState.rawValue) services")
        }
    }
    
    private func refreshTabs() {
        if let tabBarController = self.navigationController?.tabBarController {
            tabBarController.viewControllers?.forEach { viewController in
                if let nav = viewController as? UINavigationController,
                   let bookingVC = nav.viewControllers.first as? BookingsOverviewTableViewController,
                   bookingVC != self {
                    bookingVC.table.reloadData()
                } else if let bookingVC = viewController as? BookingsOverviewTableViewController,
                          bookingVC != self {
                    bookingVC.table.reloadData()
                }
            }
        }
    }
    
    @objc private func handleDataUpdate() {
        print("Notification received - reloading tab: \(currentState.rawValue)")
        Task {
            await loadBookings()
        }
    }
    
    private func loadBookings() async {
        showLoadingIndicator() // Optional
        defer { hideLoadingIndicator() }
        
        do {
            let bookings: [Booking]
            if isProvider {
                bookings = try await bookingManager.fetchBookingsForProviderAsync(userId)
            } else {
                bookings = try await bookingManager.fetchBookingsForUserAsync(LoginPageController.loggedinUser!.id!)
            }
            
            data = bookings
            
            // Update UI on main thread
            await MainActor.run {
                self.setupForCurrentTab() // This will filter and reload
            }
        } catch {
            print("❌ Failed to load: \(error.localizedDescription)")
            showAlert(message: "Failed to load bookings")
        }
    }
    
    func updateBookingState(serviceId: String, newState: BookedServiceStatus) {
        if let index = data.firstIndex(where: { $0.serviceId == serviceId }) {
            // Create a mutable copy
            var booking = data[index]
            booking.status = newState
            data[index] = booking
            refreshTabs()
            self.table.reloadData()
            
            // Notify observers (tabs) of the change
            NotificationCenter.default.post(
                name: .bookingDataDidChange,
                object: nil
            )
        }
    }
}
