import UIKit

final class BookingsTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var bookingCategory: UILabel!
    @IBOutlet weak var providedBy: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cellContextMenu: UIButton!

    var serviceId: String = ""

    // Callbacks handled by ViewController
    var onRateTapped: ((String) -> Void)?
    var onSeeDetailsTapped: ((String) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        serviceId = ""
        onRateTapped = nil
        onSeeDetailsTapped = nil
        cellContextMenu.menu = nil
    }

    func setupContextMenu(state: BookedServiceStatus) {
        guard state == .Completed else {
            cellContextMenu.menu = nil
            cellContextMenu.showsMenuAsPrimaryAction = false
            return
        }

        cellContextMenu.menu = UIMenu(children: [
            UIAction(title: "See Details") { [weak self] _ in
                guard let self else { return }
                self.onSeeDetailsTapped?(self.serviceId)
            },
            UIAction(title: "Rate", image: UIImage(systemName: "star")) { [weak self] _ in
                guard let self else { return }
                self.onRateTapped?(self.serviceId)
            }
        ])

        cellContextMenu.showsMenuAsPrimaryAction = true
        cellContextMenu.changesSelectionAsPrimaryAction = false
    }
}
