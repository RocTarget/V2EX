import UIKit
import SnapKit

class HomeViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 80
        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCell.self)
        self.view.addSubview(view)
        return view
    }()
    
    var nodes: [NodeModel] = []
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
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
        let topic = topics[indexPath.section]
        cell.topic = topic
        return cell
    }
}
