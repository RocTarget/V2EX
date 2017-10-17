import UIKit

class LoadingView: BasePlaceholderView {

    override func setupView() {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = UIDevice.isiPad ? .whiteLarge : .white
        activityIndicator.color = .gray
        self.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func placeholderViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
