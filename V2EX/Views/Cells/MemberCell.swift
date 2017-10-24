import UIKit

class MemberCell: BaseTableViewCell {

    
    override func initialize() {
        separatorInset = .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var imageFrame = imageView?.frame else { return }
        
        imageFrame.size.width = 40
        imageFrame.size.height = 40
        imageView?.frame = imageFrame
        imageView?.center.y = contentView.center.y
        
        
        guard var textLabelFrame = textLabel?.frame else { return }
        
        textLabelFrame.origin.x = imageFrame.maxX + 15
        textLabel?.frame = textLabelFrame
    }
}
