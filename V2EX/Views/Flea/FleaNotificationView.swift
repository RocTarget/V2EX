import UIKit

class FleaNotificationView: UIView {

    weak var flea: Flea?
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()

    var seat: Seat = .status

    @objc func tapLabel() {
        flea?.dismiss()
    }
}

extension FleaNotificationView: FleaContentView {
    func willBeAdded(to flea: Flea) {
        addSubview(titleLabel)

        switch seat {
        case .status:
            self.frame = CGRect(x: 0, y: 0, width: flea.bounds.width, height: 64)
            var bounds = self.bounds
            bounds.origin.y = 10
            titleLabel.numberOfLines = 2
            titleLabel.frame = bounds
        default:
            self.frame = CGRect(x: 0, y: 0, width: flea.bounds.width, height: 32)
            titleLabel.frame = self.bounds
            titleLabel.numberOfLines = 1
        }
    }
}
