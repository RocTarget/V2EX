import UIKit

public struct NodeTabViewStyle {

    public var indicatorColor = Theme.Color.globalColor
    public var titleMargin: CGFloat = 10
    public var titlePendingHorizontal: CGFloat = 14
    public var titlePendingVertical: CGFloat = 14
    public var titleFont = UIFont.systemFont(ofSize: 15)
    public var normalTitleColor = UIColor.hex(0x6C7273)
    public var selectedTitleColor = UIColor.white
    public init() {}
}

public class NodeTabView: UIControl {

    public var style: NodeTabViewStyle {
        didSet {
            reloadData()
        }
    }
    public var nodes: [NodeModel] {
        didSet {
//            guard oldValue != nodes else { return }
            reloadData()
        }
    }
    public var valueChange: ((Int) -> Void)?
    fileprivate var titleLabels: [UILabel] = []
    public fileprivate(set) var selectIndex = 0


    fileprivate  let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.isPagingEnabled = false
        view.scrollsToTop = false
        view.isScrollEnabled = true
        view.contentInset = UIEdgeInsets.zero
        view.contentOffset = CGPoint.zero
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return view
    }()

    fileprivate let selectContent =  UIView()
    fileprivate var indicator: UIView = {
        let ind = UIView()
        return ind
    }()
    fileprivate let selectedLabelsMaskView: UIView = {
        let cover = UIView()
        return cover
    }()

    //MARK:- life cycle
    public convenience init(frame: CGRect, nodes: [NodeModel]) {
        self.init(frame: frame, segmentStyle: NodeTabViewStyle(), nodes: nodes)
    }

    public init(frame: CGRect, segmentStyle: NodeTabViewStyle, nodes: [NodeModel]) {
        self.style = segmentStyle
        self.nodes = nodes
        super.init(frame: frame)
        addSubview(scrollView)
        reloadData()

        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + scrollView.contentOffset.x
        for (i, label) in titleLabels.enumerated() {
            if x >= label.frame.minX && x <= label.frame.maxX {
                setSelectIndex(index: i, animated: true)
                break
            }
        }
    }

}

//MARK: - public helper
extension NodeTabView {

    public func setSelectIndex(index: Int, animated: Bool = true) {
        guard index != selectIndex, index >= 0 , index < titleLabels.count else { return }

        let currentLabel = titleLabels[index]
        let offSetX = min(max(0, currentLabel.center.x - bounds.width / 2),
                          max(0, scrollView.contentSize.width - bounds.width))
        scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: animated)
        
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
            var rect = self.indicator.frame
            rect.origin.x = currentLabel.frame.origin.x
            rect.size.width = currentLabel.frame.size.width
            self.setIndicatorFrame(rect)
        })

        selectIndex = index
        valueChange?(index)
        sendActions(for: .valueChanged)
    }
}

//MARK: - fileprivate helper
extension NodeTabView {

    func setIndicatorFrame(_ frame: CGRect) {
        indicator.frame = frame
        selectedLabelsMaskView.frame = frame
    }

    fileprivate func reloadData() {
        guard nodes.count > 0 else { return }

        scrollView.subviews.forEach { $0.removeFromSuperview() }
        selectContent.subviews.forEach { $0.removeFromSuperview() }
        titleLabels.removeAll()

        // Set titles
        let font  = style.titleFont
        var titleX: CGFloat = 0.0
        let coverH: CGFloat = font.lineHeight + style.titlePendingVertical
        let coverY = (bounds.size.height - coverH) / 2
        
        selectedLabelsMaskView.backgroundColor = UIColor.black
        scrollView.frame = bounds
        selectContent.frame = bounds
        selectContent.layer.mask = selectedLabelsMaskView.layer
        selectedLabelsMaskView.isUserInteractionEnabled = true

        let toToSize: (String) -> CGFloat = { text in
            return (text as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).width
        }

        for (index, node) in nodes.enumerated() {

            var titleW = toToSize(node.title) + style.titlePendingHorizontal * 2
            titleW = max(titleW, 70)
            titleX = (titleLabels.last?.frame.maxX ?? 0 ) + style.titleMargin
            let rect = CGRect(x: titleX, y: coverY, width: titleW, height: coverH)

            let backLabel = UILabel()
            backLabel.tag = index
            backLabel.text = node.title
            backLabel.textColor = style.normalTitleColor
            backLabel.font = style.titleFont
            backLabel.textAlignment = .center
            backLabel.frame = rect

            let frontLabel = UILabel(frame: CGRect.zero)
            frontLabel.tag = index
            frontLabel.text = node.title
            frontLabel.textColor = style.selectedTitleColor
            frontLabel.font = style.titleFont
            frontLabel.textAlignment = .center
            frontLabel.frame = rect
            
            titleLabels.append(backLabel)
            scrollView.addSubview(backLabel)
            selectContent.addSubview(frontLabel)
            
            backLabel.autoresizingMask = .flexibleHeight
            frontLabel.autoresizingMask = .flexibleHeight

            if index == nodes.count - 1 {
                scrollView.contentSize.width = rect.maxX + style.titleMargin
                selectContent.frame.size.width = rect.maxX + style.titleMargin
            }
        }

        // Set Cover
        indicator.backgroundColor = style.indicatorColor
        scrollView.addSubview(indicator)
        scrollView.addSubview(selectContent)

        let coverX = titleLabels[0].frame.origin.x
        let coverW = titleLabels[0].frame.size.width

        let indRect = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        setIndicatorFrame(indRect)

        indicator.setCornerRadius = indicator.height * 0.5
        selectedLabelsMaskView.setCornerRadius = indicator.layer.cornerRadius

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NodeTabView.handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)

        let selecteIndex = nodes.index(where: ({ $0.isCurrent ?? false }))
        setSelectIndex(index: selecteIndex ?? 0, animated: false)
    }
}
