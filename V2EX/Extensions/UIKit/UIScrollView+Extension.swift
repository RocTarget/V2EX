import UIKit

extension UIScrollView {

    func scrollToTop(animated: Bool = true) {
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = adjustedContentInset.top
        } else {
            topInset = contentInset.top
        }
        setContentOffset(CGPoint(x: 0, y: -topInset), animated: animated)
    }

}
