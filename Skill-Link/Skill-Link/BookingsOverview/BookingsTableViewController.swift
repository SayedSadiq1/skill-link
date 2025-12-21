import UIKit

class BookingsOverviewTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        table.dataSource = self
        table.delegate = self
        
        // Register cell if not done in storyboard
        table.register(BookingsTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
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
        case upcoming
        case completed
        case canceled
    }
    
    let data: [BookedService] = [
        BookedService(state: .upcoming, title: "Cleaning Service", providedBy: "Younis", date: Date.now, time: "8:00 - 10:00 AM", location: "Manama", totalPrice: 46.3)
    ]
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookingsTableViewCell
        let booking = data[indexPath.row]
        
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        cell.serviceTitle.text = booking.title
        cell.providedBy.text = booking.providedBy
        cell.date.text = dateFormatter.string(from: booking.date)
        cell.time.text = booking.time
        cell.location.text = booking.location
        cell.price.text = "\(booking.totalPrice)BD"
        
        switch booking.state {
        case .upcoming:
            cell.bookingCategory.text = "Upcoming"
            cell.bookingCategory.backgroundColor = UIColor.tintColor
        case .completed:
            cell.bookingCategory.text = "Completed"
            cell.bookingCategory.backgroundColor = UIColor.green
        case .canceled:
            cell.bookingCategory.text = "Canceled"
            cell.bookingCategory.backgroundColor = UIColor.orange
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150 // Adjust as needed
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            table.deselectRow(at: indexPath, animated: true)
            // Handle row selection
        }
}
