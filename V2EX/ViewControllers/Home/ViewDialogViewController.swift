import Foundation
import UIKit

class ViewDialogViewController: UITableViewController {
    
    public var comments: [CommentModel]
    
    init(comments: [CommentModel]) {
        self.comments = comments
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = Theme.Color.bgColor
        tableView.keyboardDismissMode = .onDrag
        tableView.register(cellWithClass: TopicCommentCell.self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            action: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
    }
}

extension ViewDialogViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCommentCell.self)!
        let comment = comments[indexPath.row]
        cell.comment = comment
        return cell
    }
}
