import UIKit

private enum SegmentItemType: String {
    case topic = "创建的主题"
    case reply = "回复"
}

class MemberPageViewController: BaseViewController {
    
    private weak var topicViewController: MyTopicsViewController?
    private weak var replyViewController: MyReplyViewController?
    
    private lazy var segmentedView: TSegmentedView = {
        let view = TSegmentedView()
        view.delegate = self
        view.reloadData()
        view.backgroundColor = Theme.Color.bgColor
        return view
    }()
    
    private var items: [SegmentItemType] = [.reply, .topic]
    
    public var member: MemberModel
    
    init(member: MemberModel) {
        self.member = member
        
        super.init(nibName: nil, bundle: nil)
        
        let topicVC = MyTopicsViewController(username: member.username)
        let replyVC = MyReplyViewController(username: member.username)
        addChildViewController(topicVC)
        addChildViewController(replyVC)
        topicViewController = topicVC
        replyViewController = replyVC
        
        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        segmentedView.scrollView.panGestureRecognizer.require(toFail: (navigationController as! NavigationViewController).fullScreenPopGesture!)
        view.addSubview(segmentedView)
    }
    
    override func setupConstraints() {
        segmentedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MemberPageViewController: TSegmentedViewDelegate {
    func segmentedViewTitles(in segmentedView: TSegmentedView) -> [String] {
        return items.map { $0.rawValue }
    }
    
    func segmentedView(_ view: TSegmentedView, viewForIndex index: Int) -> UIView {
        guard let replyView = replyViewController?.view,
            let topicView = topicViewController?.view else {
                return UIView()
        }
        return index == 0 ? replyView : topicView
    }
    
    func segmentedViewSegmentedControlView(in segmentedView: TSegmentedView) -> (UIView & TSegmentedControlProtocol) {
        return TSegmentedControlView()
    }
    
    func segmentedViewFirstStartSelectIndex(in segmentedView: TSegmentedView) -> Int {
        return 0
    }
    
    func segmentedViewHeaderMaxHeight(in segmentedView: TSegmentedView) -> CGFloat {
        return 150
    }
    
    func segmentedViewHeaderMinHeight(in segmentedView: TSegmentedView) -> CGFloat {
        return 60
    }
    
    func segmentedViewHeaderView(in segmentedView: TSegmentedView) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .gray
        headerView.width = view.width
        headerView.height = segmentedViewHeaderMaxHeight(in: segmentedView)
        
        let avatarView = UIImageView()
            .hand.adhere(toSuperView: headerView)
            .hand.config { imageV in
                imageV.image = #imageLiteral(resourceName: "placeholder")
            }
            .hand.layout {
                $0.centerX.equalToSuperview()
                $0.size.equalTo(50)
                $0.top.equalToSuperview()
        }
        return headerView
    }
}
