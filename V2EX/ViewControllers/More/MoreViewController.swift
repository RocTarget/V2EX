import UIKit
import Carte
import MessageUI

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
//            MoreItem(icon: #imageLiteral(resourceName: "concern"), title: "特别关注", type: .follow),
            MoreItem(icon: #imageLiteral(resourceName: "topic"), title: "我的主题", type: .myTopic),
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

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setupRx() {
        NotificationCenter.default.rx
            .notification(Notification.Name.V2.LoginSuccessName)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }.disposed(by: rx.disposeBag)
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
            cell?.textLabel?.text = AccountModel.current?.username ?? item.title
            cell?.imageView?.image = item.icon
            cell?.imageView?.setRoundImage(urlString: AccountModel.current?.avatarNormalSrc, placeholder: item.icon)
        } else {
            cell?.textLabel?.text = item.title
            cell?.imageView?.image = item.icon
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 || indexPath.section == 1,  !AccountModel.isLogin {
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
        case .myTopic:
            guard let username = AccountModel.current?.username else { return }
            viewController = MyTopicsViewController(username: username)
        case .myReply:
            guard let username = AccountModel.current?.username else { return }
            viewController = MyReplyViewController(username: username)
        case .topicCollect, .follow:
            let href = type == .topicCollect ? API.topicCollect.path : API.following.path
            viewController = BaseTopicsViewController(href: href)
        case .feedback:
            sendEmail()
        case .sourceCode:
            viewController = SweetWebViewController(url: API.codeRepo.defaultURLString)
        case .libs:
            viewController = CarteViewController()
        case .about:
            viewController = SweetWebViewController(url: API.about.defaultURLString)
        case .logout:
            AccountModel.delete()
            presentLoginVC()
            // TODO: 清除 Cookies
//            HTTPCookieStorage.shared.removeCookies(since: Date())
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

extension MoreViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        
        guard MFMailComposeViewController.canSendMail() else {
            HUD.showText("操作失败，请先在系统邮件中设置个人邮箱账号。")
            return
        }

        let mailVC = MFMailComposeViewController()
        mailVC.setSubject("V2EX iOS 反馈")
        mailVC.setToRecipients([Constants.Config.receiverEmail])
        mailVC.setMessageBody("\n\n\n\n[运行环境] \(UIDevice.phoneModel)-\(UIDevice.current.systemVersion)", isHTML: false)
        mailVC.mailComposeDelegate = self
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        
        if result == .sent {
            HUD.showText("感谢您的反馈，我会尽量给您答复。")
        }else if result == .failed {
            HUD.showText("邮件发送失败: \(error?.localizedDescription ?? "Unkown")")
        }
    }
}
