import Foundation
import UIKit

class TopicDetailViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.rowHeight = 1000
        view.estimatedRowHeight = 80
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

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchTopicDetail()

        tableView.tableHeaderView = headerView

        headerView.webLoadComplete = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
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
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension TopicDetailViewController {
    func fetchTopicDetail() {
        guard let `topic` = topic else { return }

        title = topic.title
        topicDetail(topic: topic, success: { [weak self] topic in

            self?.topic = topic
            self?.tableView.reloadData()
            }, failure: nil)
    }
}
