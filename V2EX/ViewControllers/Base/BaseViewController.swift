import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    var interactivePopDisabled: Bool = false

    // MARK: Properties
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    // MARK: Initializing

    deinit {
        log.verbose("DEINIT: \(self.className)")
    }
    
    // MARK: Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Layout Constraints
    
    private(set) var didSetupConstraints = false
    
    override func viewDidLoad() {
        view.backgroundColor = Theme.Color.bgColor

        setupSubviews()
        
        view.setNeedsUpdateConstraints()
        
        setupRx()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    func setupSubviews() {
        // Override point
    }
    
    func setupConstraints() {
        // Override point
    }
    
    func setupRx() {
        // Override point
    }

    // MARK: Action
    func cancelButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
}
