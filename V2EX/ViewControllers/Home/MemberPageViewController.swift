import UIKit

class MemberPageViewController: DataViewController, MemberService {

    private lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var joinTimeLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var followBtn: UIButton = {
        let view = UIButton()
        view.setTitle("关闭", for: .normal)
        return view
    }()
    
    private lazy var blockBtn: UIButton = {
        let view = UIButton()
        view.setTitle("屏蔽", for: .normal)
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(cellWithClass: TopicCell.self)
        view.register(cellWithClass: MessageCell.self)
        return view
    }()
    
    public var memberName: String
    
    private var member: MemberModel? {
        didSet {
            guard let `member` = member else { return }
            
            avatarView.setImage(urlString: member.avatarSrc)
            usernameLabel.text = member.username
            joinTimeLabel.text = member.joinTime
            
            tableView.reloadData()
        }
    }
    private var topics: [TopicModel] = []
    private var replys: [MessageModel] = []
    
    init(memberName: String) {
        self.memberName = memberName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        headerView.addSubviews(avatarView, usernameLabel, joinTimeLabel, followBtn, blockBtn)
        
        headerView.height = 200
    }
    
    override func loadData() {
        startLoading()
        memberHome(memberName: memberName, success: { [weak self] member, topics, replys in
            self?.topics = topics
            self?.replys = replys
            self?.member = member
            self?.endLoading()
        }) { [weak self] error in
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.errorMessage = error
        }
    }
    
    override func hasContent() -> Bool {
        return member != nil
    }
    
    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        loadData()
    }
    
    override func setupConstraints() {
        
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(joinTimeLabel).offset(15)
        }
        
        avatarView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(15)
            $0.top.equalToSuperview().offset(80)
            $0.size.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView)
            $0.top.equalTo(avatarView.snp.bottom).offset(15)
        }
        
        followBtn.snp.makeConstraints {
            $0.right.equalToSuperview().inset(15)
            $0.top.equalTo(avatarView.snp.top)
            $0.width.equalTo(70)
            $0.height.equalTo(35)
        }
        
        blockBtn.snp.makeConstraints {
            $0.right.equalTo(followBtn)
            $0.top.equalTo(followBtn.snp.bottom).offset(10)
            $0.size.equalTo(followBtn)
        }
        
        joinTimeLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView)
            $0.right.equalTo(followBtn.snp.left).offset(15)
            $0.top.equalTo(usernameLabel.snp.bottom).offset(15)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}

extension MemberPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? topics.count : replys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withClass: MessageCell.self)!
        return cell
    }
}
