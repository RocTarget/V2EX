import UIKit
import StatefulViewController

class LoadingView: BasePlaceholderView, StatefulPlaceholderView {

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
        return UIEdgeInsets(top: Constants.Metric.navigationHeight, left: 0, bottom: Constants.Metric.tabbarHeight, right: 0)
    }
}
