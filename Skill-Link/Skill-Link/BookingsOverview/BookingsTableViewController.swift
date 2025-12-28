import UIKit

class BookingsOverviewTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, BookingsTableViewCellDelegate {
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        table.dataSource = self
        table.delegate = self
        
        addProviderView()
        setupForCurrentTab()
    }
    
    private var filteredData: [Booking] = []
    private var currentState: BookedServiceStatus = .Upcoming
    let isProvider = true
    
    private func addProviderView() {
        if !isProvider {
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
    
    func didTapApprove(for serviceId: UUID) {
        print("BEFORE APPROVE")
        printAllBookings()
        
        BookingDataManager.shared.updateBookingState(serviceId: serviceId, newState: .Upcoming)
        showAlert(message: "Booking approved successfully!")
        
        print("AFTER APPROVE")
        printAllBookings()
        table.reloadData()
        refreshTabs()
    }
    
    func didTapDecline(for serviceId: UUID) {
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
    
    func printAllBookings() {
        print("=== ALL BOOKINGS ===")
        for booking in BookingDataManager.shared.getAllBookings() {
            print("ID: \(booking.service.id), State: \(booking.service.state), Title: \(booking.service.title)")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BookingDataManager.shared.getBookings(for: currentState).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingsTableViewCell else {
                return UITableViewCell()
            }
            
            let booking = BookingDataManager.shared.getBookings(for: currentState)[indexPath.row]  // Use filteredData
        
        cell.delegate = self
            
            // Format the date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
        cell.serviceTitle?.text = booking.service.title
        if currentState == .Pending {
            cell.providedBy?.text = "Booked By: \(booking.user.name)"
        } else {
            if isProvider {
                cell.providedBy?.text = "Booked By: \(booking.user.name)"
            } else {
                cell.providedBy?.text = "Provided By: \(booking.provider.name)"
            }
        }
        
        cell.date?.text = dateFormatter.string(from: booking.service.date)
        cell.time?.text = booking.service.time
        cell.location?.text = booking.service.location
        cell.price?.text = "\(booking.service.totalPrice)BD"
        cell.serviceId = booking.service.id
            
            let stateLabel = cell.bookingCategory as! CardLabel
            stateLabel.alpha = CGFloat(0.65)
        stateLabel.text = booking.service.state.rawValue
        switch booking.service.state {
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
                if !isProvider {
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
