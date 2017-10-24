import UIKit

protocol EmptyViewDelegate: class {
    func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton)
}

class EmptyView: StateView {
    weak var delegate: EmptyViewDelegate?

    override func handleActionButtonTap(_ sender: UIButton) {
        delegate?.emptyView(self, didTapActionButton: sender)
    }
}
