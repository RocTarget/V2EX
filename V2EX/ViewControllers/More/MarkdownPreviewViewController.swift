import UIKit
import MarkdownView

class MarkdownPreviewViewController: BaseViewController {

    private lazy var markdownView: MarkdownView = {
        let view = MarkdownView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = UIDevice.isiPad ? .whiteLarge : .white
        activityIndicator.color = .gray
        return activityIndicator
    }()

    public var markdownString: String

    init(markdownString: String) {
        self.markdownString = markdownString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "预览"


        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain) { [weak self] in
            self?.dismiss()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        markdownView.onRendered = { [weak self] _ in
            self?.activityIndicator.stopAnimating()
        }
    }

    override func setupSubviews() {
        loadHTML()
    }

    override func setupConstraints() {
        markdownView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func loadHTML() {
        activityIndicator.startAnimating()
        markdownView.load(markdown: markdownString, enableImage: true)
    }
}
