import UIKit
import StatefulViewController

class DataViewController: UIViewController, StatefulViewController, ErrorViewDelegate, EmptyViewDelegate {

    // MARK: - Default Views

    fileprivate lazy var customEmptyView: EmptyView = {
        let emptyView = EmptyView(frame: view.frame)
        emptyView.delegate = self
        emptyView.set(status)
        return emptyView
    }()

    fileprivate lazy var customErrorView: ErrorView = {
        let errorView = ErrorView(frame: view.frame)
        errorView.delegate = self
        errorView.set(status)
        return errorView
    }()

    public var status: StatusType = .error {
        didSet {
            customEmptyView.set(status)
            customErrorView.set(status)
        }
    }

    public var errorMessage: String? {
        didSet {
            customErrorView.message = errorMessage
        }
    }

    private(set) var didSetupConstraints = false

    /// 标记有新消息时是否刷新，第一次加载不请求
    public var isLoad: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView = LoadingView()
        errorView = customErrorView
        emptyView = customEmptyView
        setupInitialViewState()

        view.backgroundColor = Theme.Color.bgColor

        setupSubviews()
        view.setNeedsUpdateConstraints()

        setupRx()

        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isLoad, hasContent() == false {
            loadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isLoad = true
    }

    deinit {
        log.verbose("DEINIT: \(className)")
    }

    // MARK: Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: Layout Constraints
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
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Required Overrides

    // EmptyViewDelegate
    func emptyView(_: EmptyView, didTapActionButton _: UIButton) {
        assertionFailure("Must be overriden in subclass")
    }

    // ErrorViewDelegate
    func errorView(_: ErrorView, didTapActionButton _: UIButton) {
        assertionFailure("Must be overriden in subclass")
    }

    // StatefulViewController
    func loadData() {
        fatalError("Must be overriden in subclass")
    }

    func hasContent() -> Bool {
        fatalError("Must be overriden in subclass")
    }
}
