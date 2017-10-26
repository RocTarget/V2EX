import UIKit
import Foundation
import Kingfisher

protocol ImageAttachmentDelegate : class {
    func imageAttachmentTap(_ imageView: UIImageView)
}

class ImageAttachment: AnimatedImageView {

    public var url: URL?

    weak var delegate : ImageAttachmentDelegate?

    init(url: URL?) {
        self.url = url
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

        contentMode = .scaleAspectFill
        isUserInteractionEnabled = true
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard image == nil else { return }

        setImage(url: url, placeholder: #imageLiteral(resourceName: "placeholder"))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let tapCount = touch?.tapCount
        if let tapCount = tapCount {
            if tapCount == 1 {
                self.handleSingleTap(touch!)
            }
        }
        //取消后续的事件响应
        next?.touchesCancelled(touches, with: event)
    }

    func handleSingleTap(_ touch:UITouch){
        delegate?.imageAttachmentTap(self)
    }
}
