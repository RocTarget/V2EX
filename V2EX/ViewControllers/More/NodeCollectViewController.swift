import UIKit

class NodeCollectViewController: BaseViewController, NodeService {

    private var nodes: [NodeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNodes()
    }

    func fetchNodes() {
        HUD.show()
        
        myNodes(success: { [weak self] nodes in
            self?.nodes = nodes
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }

}
