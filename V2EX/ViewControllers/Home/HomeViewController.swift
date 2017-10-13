import UIKit
import SnapKit

class HomeViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 80
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var tabView: NodeTabView = {
        let view = NodeTabView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: UIScreen.screenWidth,
                          height: self.navigationController!.navigationBar.height),
            nodes: nodes)
        return view
    }()
    
    var nodes: [NodeModel] = [] {
        didSet {
            tabView.nodes = nodes
        }
    }

    var topics: [TopicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        index(success: { [weak self] nodes, topics in
            guard let `self` = self else { return }
            
            self.nodes = nodes
            self.topics = topics

            }, failure: nil)

        navigationItem.titleView = tabView
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }
            let node = self.nodes[index]
            self.fetchTopic(node.href)
        }
    }

    func fetchTopic(_ href: String) {
        topics(href: href, success: { [weak self] topic in
            self?.topics = topic
        }, failure: nil)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
        let topic = topics[indexPath.row]
        cell.topic = topic
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicDetailVC = TopicDetailViewController()
        topicDetailVC.topic = topics[indexPath.row]
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }

}
