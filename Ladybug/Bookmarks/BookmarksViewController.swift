//
//  BookmarksViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController {
    let dataSourceDelegate = TableViewDataSourceDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)

        navigationController?.navigationBar.barTintColor = .barTintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.tintColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.tintColor]
        }
        navigationItem.title = "Bookmarks".localized()

        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate

        reloadData()
        RadarCollection.shared.delegates.add(delegate: self)
    }

    func reloadData() {
        let cells = RadarCollection.shared.bookmarks().map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.idString, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleFavoriteAction]), trailingSwipeActions: UISwipeActionsConfiguration(actions: [radar.deleteAction]), selectAction: {
                RadarURLOpener.shared.open(radar.id, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                }
            })
        }

        let section = TableViewSectionViewModel(header: nil, footer: nil, rows: cells)
        dataSourceDelegate.viewModel = TableViewViewModel(sections: [section])
        tableView.reloadData()
    }
}

extension BookmarksViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}
