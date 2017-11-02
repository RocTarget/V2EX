import UIKit
import MessageUI
import MobileCoreServices
import Kingfisher

enum MoreItemType {
    case user
    case createTopic, nodeCollect, myFavorites, follow, myTopic, myReply
    case nightMode, grade, sourceCode, clearCache, feedback, about, libs
    case logout
}
struct MoreItem {
    var icon: UIImage
    var title: String
    var type: MoreItemType
}

class MoreViewController: BaseViewController, AccountService, MemberService {
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.sectionHeaderHeight = 10
        view.register(cellWithClass: MoreUserCell.self)
        view.register(cellWithClass: BaseTableViewCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var imagePicker: UIImagePickerController = {
        let view = UIImagePickerController()
        view.allowsEditing = true
        view.mediaTypes = [kUTTypeImage as String]
        view.delegate = self
        return view
    }()

    private var sections: [[MoreItem]] = [
        [MoreItem(icon: #imageLiteral(resourceName: "avatar"), title: "请先登录", type: .user)],
        [
            MoreItem(icon: #imageLiteral(resourceName: "createTopic"), title: "创作新主题", type: .createTopic),
            MoreItem(icon: #imageLiteral(resourceName: "nodeCollect"), title: "节点收藏", type: .nodeCollect),
            MoreItem(icon: #imageLiteral(resourceName: "topicCollect"), title: "主题收藏", type: .myFavorites),
//            MoreItem(icon: #imageLiteral(resourceName: "concern"), title: "特别关注", type: .follow),
            MoreItem(icon: #imageLiteral(resourceName: "topic"), title: "我的主题", type: .myTopic),
            MoreItem(icon: #imageLiteral(resourceName: "myReply"), title: "我的回复", type: .myReply)
        ],
        [
            MoreItem(icon: #imageLiteral(resourceName: "nightMode"), title: "夜间模式", type: .nightMode),
//            MoreItem(icon: #imageLiteral(resourceName: "grade"), title: "给我评分", type: .grade),
            MoreItem(icon: #imageLiteral(resourceName: "cache"), title: "清除缓存", type: .clearCache),
            MoreItem(icon: #imageLiteral(resourceName: "feedback"), title: "意见反馈", type: .feedback),
            MoreItem(icon: #imageLiteral(resourceName: "sourceCode"), title: "项目源码", type: .sourceCode),
            MoreItem(icon: #imageLiteral(resourceName: "libs"), title: "开源库", type: .libs),
            MoreItem(icon: #imageLiteral(resourceName: "about"), title: "关于 V2EX", type: .about)
        ],
        [
            MoreItem(icon: #imageLiteral(resourceName: "logout"), title: "退出登录", type: .logout)
        ]
    ]

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setupSubviews() {
//        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = true
//        }
    }

    override func setupRx() {
        NotificationCenter.default.rx
            .notification(Notification.Name.V2.LoginSuccessName)
            .subscribeNext { [weak self] _ in
                self?.updateUserInfo()
        }.disposed(by: rx.disposeBag)

//        212221
        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
//                self?.view.backgroundColor = theme.bgColor
            }.disposed(by: rx.disposeBag)

    }

    private func updateUserInfo() {

        guard let username = AccountModel.current?.username else {
            HUD.dismiss()
            return
        }

        memberProfile(memberName: username, success: { [weak self] member in
            AccountModel(username: member.username, url: member.url, avatar: member.avatar).save()
            self?.tableView.reloadData()
//            self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showTest(error)
            log.error(error)
        }

        // 有缓冲，数据更新不及时， 废弃
//        userIntro(username: username, success: { [weak self] account in
//            self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
//            log.info(account)
//            HUD.dismiss()
//        }) { error in
//            HUD.dismiss()
//            log.error(error)
//        }
    }
}


extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 没有登录 不显示 退出登录 cell
        return AccountModel.isLogin ? sections.count : sections.count - 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = sections[indexPath.section][indexPath.row]
        if indexPath.section != 0 {
            let cell = tableView.dequeueReusableCell(withClass: BaseTableViewCell.self)!
            cell.textLabel?.text = item.title
            cell.imageView?.image = item.icon
            cell.selectionStyle = .none
            cell.rightType = item.type == .nightMode ? .switch : .arrow
            if item.type == .nightMode {
                cell.switchView.isOn = ThemeStyle.style.value == .night
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withClass: MoreUserCell.self)!
        cell.textLabel?.text = AccountModel.current?.username ?? item.title
        cell.imageView?.image = item.icon
        cell.imageView?.setImage(urlString: AccountModel.current?.avatarNormalSrc, placeholder: item.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 || indexPath.section == 1,  !AccountModel.isLogin {
            presentLoginVC()
            return
        }

        let item = sections[indexPath.section][indexPath.row]
        let type = item.type
        var viewController: UIViewController?
        switch type {
        case .user:
            updateAvatarHandle()
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
        case .myFavorites, .follow:
            let href = type == .myFavorites ? API.myFavorites.path : API.following.path
            viewController = BaseTopicsViewController(href: href)
        case .nightMode:
            ThemeStyle.update(style: ThemeStyle.style.value == .night ? .day : .night)
            let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell
            cell?.switchView.setOn(ThemeStyle.style.value == .night, animated: true)
        case .clearCache:
            HUD.show()
            FileManager.clearCache(complete: { size in
                HUD.dismiss()
                HUD.showText("成功清除 \(size)M 缓存")
            })
        case .feedback:
            sendEmail()
        case .sourceCode:
            viewController = SweetWebViewController(url: API.codeRepo.defaultURLString)
        case .libs:
            viewController = LibrarysViewController()
        case .about:
            viewController = SweetWebViewController(url: API.about.defaultURLString)
        case .logout:
            AccountModel.delete()
            HTTPCookieStorage.shared.cookies?.forEach({ cookie in
                HTTPCookieStorage.shared.deleteCookie(cookie)
            })
            presentLoginVC()
            tableView.reloadData()
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

extension MoreViewController {
    private func updateAvatarHandle() {
        let alertView = UIAlertController(title: "修改头像", message: nil, preferredStyle: .actionSheet)
        alertView.addAction(UIAlertAction(title: "拍照", style: .default, handler: { action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        alertView.addAction(UIAlertAction(title: "相册", style: .default, handler: { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        alertView.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            log.info("Cancle")
        }))
        present(alertView, animated: true, completion: nil)
    }

    private func uploadAvatarHandle(_ path: String) {
        HUD.show()
        updateAvatar(localURL: path, success: { [weak self] in
            self?.updateUserInfo()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }
}

extension MoreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        guard var image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        image = image.resized(by: 0.7)
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }

        let path = FileManager.document.appendingPathComponent("smfile.png")
        _ = FileManager.save(data, savePath: path)
        uploadAvatarHandle(path)
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    
    private func sendEmail() {
        
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
