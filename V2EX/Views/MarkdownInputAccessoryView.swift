//
//  MarkdownInputAccessoryView.swift
//  V2EX
//
//  Created by danxiao on 2017/10/19.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class MarkdownInputAccessoryView: UIView {

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.autoresizingMask = .flexibleWidth
        view.delaysContentTouches = true
        view.isPagingEnabled = true
        return view
    }()

    weak var textView: UITextView?

    init(height: CGFloat = 44, textView: UITextView) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: height))
        self.textView = textView

        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor.hex(0xd7d7d7)

        addSubview(scrollView)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
//        var btns: [UIButton] = []


    }
}
