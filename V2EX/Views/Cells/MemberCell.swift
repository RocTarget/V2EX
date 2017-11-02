import UIKit

class MemberCell: BaseTableViewCell {

    override func initialize() {
        separatorInset = .zero
        imageView?.setCornerRadius = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var imageFrame = imageView?.frame else { return }
        
        imageFrame.size.width = 40
        imageFrame.size.height = imageFrame.size.width
        imageView?.frame = imageFrame
        imageView?.center.y = contentView.center.y
        
        
        guard var textLabelFrame = textLabel?.frame else { return }
        
        textLabelFrame.origin.x = imageFrame.maxX + 15
        textLabel?.frame = textLabelFrame
    }
}


class MoreUserCell: BaseTableViewCell {

    override func initialize() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard var imageFrame = imageView?.frame else { return }

        imageFrame.size.width = 50
        imageFrame.size.height = imageFrame.size.width
        imageView?.frame = imageFrame
        imageView?.center.y = contentView.center.y
        imageView?.setCornerRadius = imageFrame.height.half

        guard var textLabelFrame = textLabel?.frame else { return }

        textLabelFrame.origin.x = imageFrame.maxX + 15
        textLabel?.frame = textLabelFrame
    }
}


