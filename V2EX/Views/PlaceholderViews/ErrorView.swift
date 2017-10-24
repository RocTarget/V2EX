import UIKit


protocol ErrorViewDelegate: class {
    func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton)
}

class ErrorView: StateView {

    weak var delegate: ErrorViewDelegate?

    override func handleActionButtonTap(_ sender: UIButton) {
        delegate?.errorView(self, didTapActionButton: sender)
    }
}

