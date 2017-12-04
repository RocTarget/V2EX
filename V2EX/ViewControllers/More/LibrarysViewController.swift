import UIKit

class LibrarysViewController: BaseViewController {

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(cellWithClass: BaseTableViewCell.self)
        view.backgroundColor = .clear
        self.view.addSubview(view)
        return view
    }()

    // MARK: - Propertys
    
    private let dataSource: [(title: String, intro: String, link: String)] = [
        ("Alamofire", "Elegant HTTP Networking in Swift", "https://github.com/Alamofire/Alamofire"),
        ("Kingfisher", "A lightweight, pure-Swift library for downloading and caching images from the web.", "https://github.com/onevcat/Kingfisher"),
        ("RxSwift", "RxSwift is a Swift implementation of Reactive Extensions", "https://github.com/ReactiveX/RxSwift"),
        ("RxCocoa", "RxSwift Cocoa extensions", "https://github.com/ReactiveX/RxSwift"),
        ("RxOptional", "RxSwift extensions for Swift optionals and Occupiable types", "https://github.com/RxSwiftCommunity/RxOptional"),
        ("NSObject+Rx", "Handy RxSwift extensions on NSObject.", "https://github.com/RxSwiftCommunity/NSObject-Rx"),
        ("Kanna", "Kanna is an XML/HTML parser for iOS/macOS/watchOS/tvOS and Linux.", "https://github.com/tid-kijyun/Kanna"),
        ("SnapKit", "Harness the power of auto layout with a simplified, chainable, and compile time safe syntax.", "https://github.com/SnapKit/SnapKit"),
        ("UIView+Positioning", "UIView+Positioning provides shorthand methods and helpers to define the frame", "https://github.com/freak4pc/UIView-Positioning"),
        ("PKHUD", " A Swift 3 based reimplementation of the Apple HUD (Volume, Ringer, Rotation,…) for iOS8 and up", "https://github.com/pkluz/PKHUD"),
        ("SwiftMessages", "A very flexible message bar for iOS written in Swift.", "https://github.com/SwiftKickMobile/SwiftMessages"),
        ("StatefulViewController", "Placeholder views based on content, loading, error or empty states", "https://github.com/aschuch/StatefulViewController"),
        ("YYText", "Powerful text framework for iOS to display and edit rich text.", "https://github.com/ibireme/YYText"),
        ("SKPhotoBrowser", "Simple PhotoBrowser/Viewer inspired by facebook, twitter photo browsers written by swift.", "https://github.com/suzuki-0000/SKPhotoBrowser"),
        ("PullToRefreshKit", "A refresh library written with pure Swift 3", "https://github.com/LeoMobileDeveloper/PullToRefreshKit"),
        ("MarkdownView", "Markdown View for iOS.", "https://github.com/keitaoouchi/MarkdownView"),
        ("IQKeyboardManagerSwift", "Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView.", "https://github.com/hackiftekhar/IQKeyboardManager"),
        ("Crashlytics", "Best and lightest-weight crash reporting for mobile, desktop and tvOS.", "http://try.crashlytics.com/"),
    ]

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "致谢"
        
        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
            self?.tableView.separatorColor = theme.borderColor
        }.disposed(by: rx.disposeBag)
    }

    // MARK: - Setup

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LibrarysViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: BaseTableViewCell.self)!
        cell.accessoryType = .disclosureIndicator
        let item = dataSource[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.intro
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataSource[indexPath.row]
        openWebView(url: item.link)
    }
}
