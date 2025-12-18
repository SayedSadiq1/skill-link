//
//  UpcomingTableViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 18/12/2025.
//

import UIKit

class UpcomingTableViewController: UITableViewController {

    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UpcomingTableViewCell
        let booking = data[indexPath.row]
        cell.bookingCategory.text = booking.state.rawValue
        cell.serviceTitle.text = booking.title
        cell.providedBy.text = booking.providedBy
        cell.date.text = DateFormatter().string(from: booking.date)
        cell.time.text = booking.time
        cell.location.text = booking.location
        cell.price.text = "\(booking.totalPrice)BD"
        
        return cell
    }
}
