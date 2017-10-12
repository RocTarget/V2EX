import UIKit

class BaseTableViewCell: UITableViewCell {

    // MARK: Initializing
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        separatorInset = .zero
        //        textLabel?.textColor = Theme.Color.shallowBlack
        initialize()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialize() {
        // Override point
    }

    func setupConstraints() {
        // Override point
    }
}
