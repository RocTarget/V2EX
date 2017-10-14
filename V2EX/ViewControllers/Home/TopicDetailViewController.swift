import Foundation
import UIKit

class TopicDetailViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.estimatedRowHeight = 80
        view.backgroundColor = .clear
        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCommentCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var headerView: TopicDetailHeaderView = {
        return TopicDetailHeaderView()
    }()

    var topic: TopicModel? {
        didSet {
            headerView.topic = topic
        }
    }

    var comments: [CommentModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchTopicDetail()

        headerView.isHidden = true
        tableView.tableHeaderView = headerView
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCommentCell.self)!
        cell.comment = comments[indexPath.row]
        return cell
    }
}

extension TopicDetailViewController {
    func fetchTopicDetail() {
        guard let `topic` = topic else { return }

        ProgressHUD.show()

        title = topic.title
        topicDetail(topic: topic, success: { [weak self] topic, comments in
            self?.topic = topic
            self?.comments = comments

            ProgressHUD.dismiss()
            }, failure: { error in
                ProgressHUD.dismiss()
                ProgressHUD.showText(error)
        })

        headerView.webLoadComplete = { [weak self] in
            self?.headerView.isHidden = false
            self?.tableView.reloadData()
        }
    }
}
