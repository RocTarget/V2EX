import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class FleaAlertView: UIView {
    weak var flea: Flea?

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var subTitle: String? {
        get {
            return subTitleLabel.text
        }
        set {
            subTitleLabel.text = newValue
        }
    }

    var actionItems = [FleaActionItem]()

    var titleLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0

        return label
    }()
    var subTitleLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = Theme.Color.navColor
        label.textAlignment = .center
        label.fontSize = 15
        label.numberOfLines = 0

        return label
    }()

    fileprivate var buttons = [UIButton]()
}

extension FleaAlertView: FleaContentView {
    func willBeAdded(to flea: Flea) {
        addSubview(titleLabel)
        addSubview(subTitleLabel)

        let contentWidth: CGFloat = 316
        let textMargin: CGFloat = 20
        let textLRMargin: CGFloat = 10
        let textWidth = contentWidth - textLRMargin * 2
        var maxY: CGFloat = 0

        titleLabel.frame = CGRect(x: 0, y: 0, width: textWidth, height: 0)
        titleLabel.sizeToFit()

        subTitleLabel.frame = CGRect(x: 0, y: 0, width: textWidth, height: 0)
        subTitleLabel.sizeToFit()

        if titleLabel.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            titleLabel.frame = CGRect(x: textLRMargin, y: textMargin, width: textWidth, height: titleLabel.height)
            maxY = titleLabel.frame.maxY
        }
        if subTitleLabel.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            let height = titleLabel.text?.length > 0 ? subTitleLabel.frame.height : subTitleLabel.height > 30 ? subTitleLabel.frame.height : subTitleLabel.height + 32
            subTitleLabel.frame = CGRect(x: textLRMargin, y: maxY + textMargin, width: textWidth, height: height)
            maxY = subTitleLabel.frame.maxY
        }
        maxY += textMargin

        if actionItems.count == 1 {
            let button1 = UIButton(type: .custom)
            button1.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button1.backgroundColor = Theme.Color.globalColor
            button1.setTitle(actionItems[0].title, for: UIControlState())
            button1.setTitleColor(actionItems[0].color, for: UIControlState())

            button1.frame = CGRect(x: 0, y: maxY, width: contentWidth, height: 50)
            maxY += button1.height

            button1.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)

            addSubview(button1)
            buttons.append(button1)
        } else if actionItems.count == 2 {
            let button1 = UIButton(type: .custom)
            let button2 = UIButton(type: .custom)
            button1.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button2.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button1.borderTop = Border()

            button1.backgroundColor = .white
            button2.backgroundColor = Theme.Color.globalColor
            button1.setTitle(actionItems[0].title, for: UIControlState())
            button1.setTitleColor(actionItems[0].color, for: UIControlState())
            button2.setTitle(actionItems[1].title, for: UIControlState())
            button2.setTitleColor(actionItems[1].color, for: UIControlState())

            button1.frame = CGRect(x: 0, y: maxY, width: contentWidth * 0.5, height: 50)
            button2.frame = CGRect(x: contentWidth * 0.5, y: maxY, width: contentWidth * 0.5, height: button1.height)
            maxY += button1.height

            button1.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
            button2.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)

            addSubview(button1)
            addSubview(button2)
            buttons.append(contentsOf: [button1, button2])
        } else {
            for item in actionItems {
                let button = UIButton(type: .custom)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                button.borderTop = Border()
                button.setTitle(item.title, for: UIControlState())
                button.setTitleColor(item.color, for: UIControlState())
                button.frame = CGRect(x: 0, y: maxY, width: contentWidth, height: 44)
                maxY += button.height

                button.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
                addSubview(button)
                buttons.append(button)
            }
        }

        self.frame = CGRect(x: 0, y: 0, width: contentWidth, height: maxY)
    }
    @objc fileprivate func onTapButton(_ sender: UIButton) {
        let index = buttons.index(of: sender)!
        let item = actionItems[index]

        item.action?()
        flea?.dismiss()
    }
}
