//
//  HistoryViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {
    let dataSourceDelegate = TableViewDataSourceDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)

        navigationController?.navigationBar.barTintColor = .barTintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.tintColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.tintColor]
        }
        navigationItem.title = "History".localized()

        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate

        reloadData()
        RadarCollection.shared.delegates.add(delegate: self)
    }

    func reloadData() {
        let cells = RadarCollection.shared.history().map { (radar) -> TableViewCellViewModel in
            let viewModel = TableViewCellViewModel(title: radar.idString, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleFavoriteAction]), trailingSwipeActions: UISwipeActionsConfiguration(actions: [radar.deleteAction]), selectAction: {
                try? RadarCollection.shared.updatedViewed(radarID: radar.id)
                RadarURLOpener.shared.open(radar.id, radarOption: UserDefaults.standard.radarOption,  in: UserDefaults.standard.browserOption) { (result) in
                }
            })

            return viewModel
        }

        let section = TableViewSectionViewModel(header: nil, footer: nil, rows: cells)
        dataSourceDelegate.viewModel = TableViewViewModel(sections: [section])
        tableView.reloadData()
    }
}

extension HistoryViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}
