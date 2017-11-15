import UIKit


class SettingViewController: UITableViewController {

    enum SettingItemType {
        case browser, nightMode, fontSize, logout, fullScreenBack
    }
    struct SettingItem {
        var title: String
        var type: SettingItemType
        var rightType: RightType
    }

    private var sections: [[SettingItem]] = [
        [
            SettingItem(title: "使用 Safari 浏览网页", type: .browser, rightType: .switch),
            SettingItem(title: "全屏返回手势", type: .fullScreenBack, rightType: .switch),
            SettingItem(title: "夜间模式", type: .nightMode, rightType: .switch),
            SettingItem(title: "调节字体", type: .fontSize, rightType: .arrow),
        ],
        [
            SettingItem(title: "退出账号", type: .logout, rightType: .none)
        ]
    ]

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeStyle.style.value.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellWithClass: BaseTableViewCell.self)

        ThemeStyle.style
            .asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.backgroundColor = theme.bgColor
                self?.tableView.separatorColor = theme.borderColor
        }.disposed(by: rx.disposeBag)
    }

}

extension SettingViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AccountModel.isLogin ? sections.count : sections.count - 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: BaseTableViewCell.self)!
        cell.selectionStyle = .none
        
        let item = sections[indexPath.section][indexPath.row]
        cell.textLabel?.text = item.title
        cell.rightType = item.rightType
        cell.textLabel?.textAlignment = item.type == .logout ? .center : .left
        switch item.type {
        case .browser:
            cell.switchView.isOn = (UserDefaults.get(forKey: Constants.Keys.openWithSafariBrowser) as? Bool) ?? false
        case .fullScreenBack:
            cell.switchView.isOn = (UserDefaults.get(forKey: Constants.Keys.fullScreenBack) as? Bool) ?? true
        case .nightMode:
            cell.switchView.isOn = ThemeStyle.style.value == .night
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell else { return }
        cell.switchView.setOn(!cell.switchView.isOn, animated: true)
        let item = sections[indexPath.section][indexPath.row]

        switch item.type {
        case .browser:
            UserDefaults.save(at: cell.switchView.isOn, forKey: Constants.Keys.openWithSafariBrowser)
        case .fullScreenBack:
            UserDefaults.save(at: cell.switchView.isOn, forKey: Constants.Keys.fullScreenBack)
        case .nightMode:
            ThemeStyle.update(style: ThemeStyle.style.value == .night ? .day : .night)
        case .fontSize:
            let adjustFontVC = AdjustFontViewController()
            navigationController?.pushViewController(adjustFontVC, animated: true)
        case .logout:
            AccountModel.delete()
            HTTPCookieStorage.shared.cookies?.forEach({ cookie in
                HTTPCookieStorage.shared.deleteCookie(cookie)
            })
            presentLoginVC()
            tableView.reloadData()
        }

    }
}
