import UIKit

class BookingsOverviewTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        table.dataSource = self
        table.delegate = self
        
        addProviderView()
        setupForCurrentTab()
    }
    
    let data: [BookedService] = [
        BookedService(state: .completed, title: "Cleaning Service", providedBy: "Provided By: Younis", date: Date.now, time: "8:00 - 10:00 AM", location: "Manama", totalPrice: 46.3),
        BookedService(state: .canceled, title: "Lights Replacement", providedBy: "Provided By: Ahmed", date: Date.now, time: "1:00 - 2:00 PM", location: "Sanabis", totalPrice: 5.25),
        BookedService(state: .upcoming, title: "Garage Door Installation", providedBy: "Provided By: Jamous", date: Date.now, time: "12:00 - 4:00 PM", location: "Saar", totalPrice: 30),
        BookedService(state: .pending, title: "Deep cleaning", providedBy: "Requested By: Murtadha", date: Date.now, time: "4:00 - 9:00 PM", location: "Zallaq Pier", totalPrice: 140)
    ]
    
    private var filteredData: [BookedService] = []
    private var currentState: BookedServiceStatus = .upcoming
    let isProvider = true
    
    struct BookedService {
        let state: BookedServiceStatus
        let title: String
        let providedBy: String
        let date: Date
        let time: String
        let location: String
        let totalPrice: Double
    }
    
    enum BookedServiceStatus: String {
        case pending
        case upcoming
        case completed
        case canceled
    }
    
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
            
            cell.serviceTitle?.text = booking.title
            cell.providedBy?.text = booking.providedBy
            cell.date?.text = dateFormatter.string(from: booking.date)
            cell.time?.text = booking.time
            cell.location?.text = booking.location
            cell.price?.text = "\(booking.totalPrice)BD"
            
            let stateLabel = cell.bookingCategory as! CardLabel
            stateLabel.alpha = CGFloat(0.65)
            
            switch booking.state {
            case .pending:
                stateLabel.text = "Pending"
                stateLabel.setBackgroundColor(UIColor.yellow)
            case .upcoming:
                stateLabel.text = "Upcoming"
                stateLabel.setBackgroundColor(UIColor.tintColor)
            case .completed:
                stateLabel.text = "Completed"
                stateLabel.setBackgroundColor(UIColor.systemGreen)
            case .canceled:
                stateLabel.text = "Canceled"
                stateLabel.setBackgroundColor(UIColor.orange)
            }
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 230
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
                        currentState = .upcoming
                    case 1:
                        currentState = .completed
                    case 2:
                        currentState = .canceled
                    default:
                        break
                    }
                } else {
                    switch index {
                    case 0:
                        currentState = .pending
                    case 1:
                        currentState = .upcoming
                    case 2:
                        currentState = .completed
                    case 3:
                        currentState = .canceled
                    default:
                        break
                    }
                }
                
                
                // Filter the data
                filteredData = data.filter { $0.state == currentState }
                
                // Reload table
                table.reloadData()
                
                // Debug
                print("Tab \(index): Showing \(filteredData.count) \(currentState.rawValue) services")
            }
        }
}
