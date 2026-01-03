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
        
        userService.signIn(email: "123@123.com", password: "123123") {_ in }
        // Set up the table view
        table.dataSource = self
        table.delegate = self
        
        if isProvider {
            bookingManager.fetchBookingsForProvider(userId) { [weak self] result in
                switch result {
                case .success(let bookings):
                    print("Found \(bookings.count) for provider: \(String(describing: self?.userId))")
                    self?.data = bookings
                    self?.filteredData = bookings.filter({booking in booking.status == self?.currentState})
                    self?.table.reloadData()
                    self?.refreshTabs()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            bookingManager.fetchBookingsForUser(LoginPageController.loggedinUser!.id){ [weak self] result in
                switch result {
                case .success(let bookings):
                    print("Found \(bookings.count) for seeker: \(String(describing: self?.userId))")
                    self?.data = bookings
                    self?.filteredData = bookings.filter({booking in booking.status == self?.currentState})
                    self?.table.reloadData()
                    self?.refreshTabs()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
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
    
    func didTapApprove(for serviceId: String) {
        BookingDataManager.shared.updateBookingState(serviceId: serviceId, newState: .Upcoming)
        showAlert(message: "Booking approved successfully!")
        table.reloadData()
        refreshTabs()
    }
    
    func didTapDecline(for serviceId: String) {
        BookingDataManager.shared.updateBookingState(serviceId: serviceId, newState: .Canceled)
        showAlert(message: "Booking declined")
        table.reloadData()
        refreshTabs()
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
                    cell!.providedBy?.text = "Booked By: \(user.name)"
                } else {
                    if self!.isProvider {
                        cell!.providedBy?.text = "Booked By: \(user.name)"
                    } else {
                        cell!.providedBy?.text = "Provided By: \(user.name)"
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
        cell.serviceId = booking.serviceId
        
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
}
