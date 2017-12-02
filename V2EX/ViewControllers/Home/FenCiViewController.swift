import UIKit
import RxSwift
import RxCocoa

class FenCiViewController: UICollectionViewController {
    
    // MARK: - UI
    
    private lazy var toolBarView: UIView = {
        let view = UIView()
        view.addSubviews(copyBtn, searchBtn)
        self.view.addSubview(view)
        view.backgroundColor = ThemeStyle.style.value.whiteColor
        view.isUserInteractionEnabled = false
        view.alpha = 0.5
        return view
    }()
    
    private lazy var copyBtn: UIButton = {
        let view = UIButton()
        view.setTitle("复制", for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        view.setTitleColor(Theme.Color.globalColor, for: .normal)
        return view
    }()
    
    private lazy var searchBtn: UIButton = {
        let view = UIButton()
        view.setTitle("搜索", for: .normal)
        view.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        view.setTitleColor(Theme.Color.globalColor, for: .normal)
        return view
    }()
    
    
    // MARK: - Propertys
    
    private var words: [String]
    
    private var selectWords: [String] {
        guard let selectedItems = collectionView?.indexPathsForSelectedItems else { return [] }
        return selectedItems.sorted().flatMap { indexPath -> String? in
            return words[indexPath.row]
        }
    }
    
    // MARK: - View Life Cycle
    
    init(text: String) {
        words = text.bang
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.cellSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 0)
        layout.minimumLineSpacing = 5
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "分词"

        setupCollectionView()
        setupConstraints()
        setupRx()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeStyle.style.value.statusBarStyle
    }
    
    deinit {
        log.verbose(className + " Deinit")
    }
    // MARK: - Setup
    
    private func setupCollectionView() {
        collectionView?.register(FenCiCell.self, forCellWithReuseIdentifier: FenCiCell.description())
        collectionView?.backgroundColor = ThemeStyle.style.value.whiteColor
        collectionView?.allowsMultipleSelection = true
        collectionView?.layer.borderColor = ThemeStyle.style.value.borderColor.cgColor
        collectionView?.layer.borderWidth = 1
        
        collectionView?.height -= 55
    }
    
    private func setupConstraints() {
        toolBarView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(55)
        }
        
        searchBtn.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        
        copyBtn.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.width.equalTo(searchBtn)
        }
    }
    
    private func setupRx() {
        
        copyBtn.rx.tap
            .subscribeNext { [weak self] in
                UIPasteboard.general.string = self?.selectWords.joined()
                HUD.showSuccess("已复制到剪贴板")
            }.disposed(by: rx.disposeBag)
        
        searchBtn.rx.tap
            .subscribeNext { [weak self] in
                guard let text = self?.selectWords.joined() else {
                    HUD.showError("当前没有选择内容")
                    return
                }
                openWebView(url: "https://m.baidu.com/s?wd=\(text)")
            }.disposed(by: rx.disposeBag)
        
        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.collectionView?.layer.borderColor = theme == .day ? theme.borderColor.cgColor : UIColor.black.withAlphaComponent(0.5).cgColor
        }.disposed(by: rx.disposeBag)
    }
}

extension FenCiViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FenCiCell.description(), for: indexPath) as! FenCiCell
        cell.title = words[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toolBarView.isUserInteractionEnabled = true
        toolBarView.alpha = 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (collectionView.indexPathsForSelectedItems?.count ?? 0) == 0 {
            toolBarView.isUserInteractionEnabled = false
            toolBarView.alpha = 0.5
        }
    }
}

extension FenCiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = words[indexPath.row]
        let w = item.toWidth(fontSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        return CGSize(width: w + 20, height: 30)
    }
}
