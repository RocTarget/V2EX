//
//  MemberListViewController.swift
//  V2EX
//
//  Created by danxiao on 2017/10/24.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class MemberListViewController: UITableViewController {

    private struct ReuseIdentifiers {
        static let cell = "MemberCell"
    }

    public var members: [MemberModel] = []

    public var callback: (([MemberModel]) -> Void)?

    init(members: [MemberModel]) {
        super.init(style: .plain)
        self.members = members
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.verbose("DEINIT MemberListViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = true
        tableView.setEditing(true, animated: true)
        tableView.tintColor = Theme.Color.globalColor
        tableView.rowHeight = 60

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, action: {
            self.dismiss(animated: true, completion: nil)
        })

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, action: { [weak self] in

            var memberList: [MemberModel] = []
            self?.tableView.indexPathsForSelectedRows?.forEach({ [weak self] indexPath in
                if let member = self?.members[indexPath.row] {
                    memberList.append(member)
                }
            })

            self?.dismiss(animated: true, completion: {
                self?.callback?(memberList)
            })
        })
    }
}

extension MemberListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.cell)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifiers.cell)
            cell?.imageView?.snp.makeConstraints {
                $0.size.equalTo(40)
                $0.centerY.equalToSuperview()
            }
        }
        cell?.textLabel?.text = members[indexPath.row].username
        cell?.imageView?.setImage(urlString: members[indexPath.row].avatarSrc, placeholder: #imageLiteral(resourceName: "avatar"))
        return cell!
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let type = UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue
        return UITableViewCellEditingStyle(rawValue: type)!
    }
}

