import UIKit

class HoverView: UIView {
    
    private lazy var segmentView: UISegmentedControl = {
        let view = UISegmentedControl()
        view.tintColor = .clear
        view.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor.black
            ], for: .normal)
        view.setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
             NSAttributedStringKey.foregroundColor: Theme.Color.globalColor
            ], for: .selected)
        view.addTarget(self, action: #selector(segmentClickAction), for: .valueChanged)
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.bounces = false
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Color.globalColor
        return view
    }()
    
    private var titles: [String]
    
    public var didChangePage:((Int) -> Void)?
    
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubviews(segmentView, lineView, scrollView)

        lineView.width = width / titles.count.f
        lineView.center = CGPoint(x: width / titles.count.f / 2, y: 40)
    }
    
    
    @objc private func segmentClickAction() {
        
    }
    
    private func didChangePage(_ page: Int) {
        
        let lineCenterX = width / titles.count.f / 2 + page.f * (width / titles.count.f)
        UIView.transition(with: lineView,
                          duration: 0.3,
                          options: .allowUserInteraction,
                          animations: {
                        self.lineView.centerX = lineCenterX
        }, completion: nil)
        didChangePage?(page)
    }
}

extension HoverView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / width)
        self.segmentView.selectedSegmentIndex = page
        didChangePage(page)
    }
}
