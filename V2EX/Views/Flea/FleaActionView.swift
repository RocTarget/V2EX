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

struct FleaActionItem {
    var title = ""
    var color = UIColor.black
    var action: (() -> Void)?
}

class FleaActionView: UIView {
    weak var flea: Flea?

    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    var subTitle: String? {
        set {
            subTitleLabel.text = newValue
        }
        get {
            return subTitleLabel.text
        }
    }

    var actionItems = [FleaActionItem]()

    var titleLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = FleaPalette.DarkGray
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0

        return label
    }()
    var subTitleLabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = FleaPalette.LightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0

        return label
    }()
    fileprivate var buttons = [FleaActionButton]()
}

extension FleaActionView: FleaContentView {
    func willBeAdded(to flea: Flea) {

        let textMargin: CGFloat = subTitle == nil && title == nil ? 0 : 20
        let textWidth = flea.bounds.width - textMargin * 2
        var maxY: CGFloat = 0

        if title?.count != 0 || title != nil {
            addSubview(titleLabel)
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: textMargin, y: textMargin, width: textWidth, height: titleLabel.frame.height)
            maxY = titleLabel.frame.maxY
        }

        if subTitle?.count != 0 || title != nil {
            addSubview(subTitleLabel)
            subTitleLabel.sizeToFit()
            subTitleLabel.frame = CGRect(x: textMargin, y: maxY + textMargin, width: textWidth, height: subTitleLabel.frame.height)
            maxY = subTitleLabel.frame.maxY
        }

        if subTitleLabel.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 {
        }
        maxY += textMargin

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        self.addGestureRecognizer(tap)

        var count = 0

        let height: CGFloat = 54

        for item in actionItems {
            count += 1

            let button = FleaActionButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitle(item.title, for: UIControlState())
            button.setTitleColor(item.color, for: UIControlState())
            button.frame = CGRect(x: 0, y: maxY, width: flea.bounds.width, height: height)
            button.addTarget(self, action: #selector(onTapAction(_:)), for: .touchUpInside)
            addSubview(button)
            buttons.append(button)
            maxY += height

            if count == actionItems.count {
                print(count)
                let view = UIView()
                view.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1)
                view.frame = CGRect(x: 0, y: maxY, width: flea.bounds.width, height: 10)
                addSubview(view)
                maxY += 10

                let button = FleaActionButton(type: .custom)
                button.titleLabel?.fontSize = 15
                button.setTitle("取消", for: UIControlState())
                button.setTitleColor(item.color, for: UIControlState())
                button.frame = CGRect(x: 0, y: maxY, width: flea.width, height: height)
                button.addTarget(self, action: #selector(self.dismiss), for: .touchUpInside)
                addSubview(button)
                maxY += height
            }
        }

        self.frame = CGRect(x: 0, y: 0, width: flea.width, height: maxY)
    }
    @objc func onTap(_ sender: AnyObject) {

    }

    @objc func onTapAction(_ sender: AnyObject) {
        guard let button = sender as? FleaActionButton,
            let index = buttons.index(of: button) else { return }
        let item = actionItems[index]

        item.action?()
        flea?.dismiss()
    }

    @objc func dismiss() {
        flea?.dismiss()
    }
}

class FleaActionButton: UIButton {

    let line = { () -> UIView in
        let line = UIView()
        line.backgroundColor = FleaPalette.DarkWhite

        return line
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(line)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        line.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        backgroundColor = FleaPalette.DarkWhite
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        backgroundColor = UIColor.white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        backgroundColor = UIColor.white
    }
}
