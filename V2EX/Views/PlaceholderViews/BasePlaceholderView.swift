import UIKit
import StatefulViewController

class BasePlaceholderView: UIView, StatefulViewController {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setupView()
	}
	
	func setupView() {        

    }
}
