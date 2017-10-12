import UIKit

class HomeViewController: BaseViewController, TopicService {

    override func viewDidLoad() {
        super.viewDidLoad()

        index(success: { (nodes, topics) in
            
        }, failure: nil)
    }

}
