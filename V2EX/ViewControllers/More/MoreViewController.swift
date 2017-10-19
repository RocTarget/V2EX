import UIKit
import Carte

enum MoreItemType {
    case user
    case createTopic, nodeCollect, topicCollect, follow, myTopic, myReply
    case nightMode, grade, sourceCode, feedback, about, libs
    case logout
}
struct MoreItem {
    var icon: UIImage
    var title: String
    var type: MoreItemType
}

class MoreViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.sectionHeaderHeight = 10
        self.view.addSubview(view)
        return view
    }()
    
    var sections: [[MoreItem]] = [
        [MoreItem(icon: #imageLiteral(resourceName: "avatar"), title: "请先登录", type: .user)],
        [
            MoreItem(icon: #imageLiteral(resourceName: "createTopic"), title: "创作新主题", type: .createTopic),
            MoreItem(icon: #imageLiteral(resourceName: "nodeCollect"), title: "节点收藏", type: .nodeCollect),
            MoreItem(icon: #imageLiteral(resourceName: "topicCollect"), title: "主题收藏", type: .topicCollect),
            MoreItem(icon: #imageLiteral(resourceName: "concern"), title: "特别关注", type: .follow),
            MoreItem(icon: #imageLiteral(resourceName: "topic"), title: "我的话题", type: .myTopic),
            MoreItem(icon: #imageLiteral(resourceName: "myReply"), title: "我的回复", type: .myReply)
        ],
        [
            MoreItem(icon: #imageLiteral(resourceName: "nightMode"), title: "夜间模式", type: .nightMode),
            MoreItem(icon: #imageLiteral(resourceName: "grade"), title: "给我评分", type: .grade),
            MoreItem(icon: #imageLiteral(resourceName: "feedback"), title: "意见反馈", type: .feedback),
            MoreItem(icon: #imageLiteral(resourceName: "sourceCode"), title: "项目源码", type: .sourceCode),
            MoreItem(icon: #imageLiteral(resourceName: "libs"), title: "开源库", type: .libs),
            MoreItem(icon: #imageLiteral(resourceName: "about"), title: "关于 V2EX", type: .about)
        ],
        [
            MoreItem(icon: #imageLiteral(resourceName: "logout"), title: "退出登录", type: .logout)
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        view.animateRandom()
    }
}


extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MoreItemCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MoreItemCell")
            cell?.accessoryType = .disclosureIndicator
        }
        
        let item = sections[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            cell?.textLabel?.text = UserModel.current()?.username ?? item.title
            cell?.imageView?.setRoundImage(urlString: UserModel.current()?.avatarNormalSrc, placeholder: item.icon)
        } else {
            cell?.textLabel?.text = item.title
            cell?.imageView?.image = item.icon
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 || indexPath.section == 1,  !UserModel.isLogin {
            presentLoginVC()
            return
        }

        let item = sections[indexPath.section][indexPath.row]
        let type = item.type
        var viewController: UIViewController?
        switch type {
        case .user:
            break
        case .createTopic:
            viewController = CreateTopicViewController()
        case .nodeCollect:
            viewController = NodeCollectViewController()
        case .topicCollect, .follow:
            let href = type == .topicCollect ? API.topicCollect.path : API.following.path
            viewController = TopicsViewController(href: href)
        case .sourceCode:
            viewController = SweetWebViewController(url: "https://github.com/Joe0708/V2EX")
        case .libs:
            viewController = CarteViewController()
        case .about:
            viewController = SweetWebViewController(url: "https://www.v2ex.com/about")
        default:
            break
        }
        guard let vc = viewController else { return }
        
        vc.title = item.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 80 : 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


extension URLComponents {
    subscript(key: String) -> String? {
        return queryItems?.filter { $0.name == key }.first?.value
    }
    
    /// 不包含 '/'
    var pathString: String {
        return path.deleteOccurrences(target: "/")
    }
}
