import UIKit

class MemberPageViewController: BaseViewController {
    
    private weak var topicViewController: MyTopicsViewController?
    private weak var replyViewController: MyReplyViewController?


    public var member: MemberModel
    
    init(member: MemberModel) {
        self.member = member
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
