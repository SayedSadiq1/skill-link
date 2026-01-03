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
    
    let data: [Booking] = [
        // PENDING: Waiting for provider acceptance
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        ),
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        ),
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        )
    ]
    
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
