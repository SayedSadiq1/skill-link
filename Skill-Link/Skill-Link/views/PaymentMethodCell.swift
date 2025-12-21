import UIKit

class PaymentMethodCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var paymentMethodImageView: UIImageView!
    @IBOutlet weak var paymentMethodNameLabel: UILabel!
    
    var destination : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = UIColor(hex: "#182E61")
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true

        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        paymentMethodImageView.image = nil
        paymentMethodNameLabel.text = nil
    }

    func configure(name: String, imageName: String, destination: String?) {
        paymentMethodNameLabel.text = name
        paymentMethodImageView.image = UIImage(named: imageName)
        self.destination = destination
    }
}

