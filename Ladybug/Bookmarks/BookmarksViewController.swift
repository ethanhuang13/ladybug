//
//  BookmarksViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController, TableViewControllerUsingViewModel {
    lazy var dataSourceDelegate: TableViewDataSourceDelegate = { TableViewDataSourceDelegate(tableViewController: self) }()

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

        RadarCollection.shared.delegates.add(delegate: self)
    }

    func reloadData() {
        let cells = RadarCollection.shared.bookmarks().map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: radar.cellSubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: nil, previewingViewController: {
                let url = radar.id.url(by: .openRadar)
                return (self.tabBarController as? TabBarController)?.safariViewController(url: url, readerMode: UserDefaults.standard.browserOption == .sfvcReader)
            }, selectAction: {
                RadarURLOpener.shared.open(radar.id, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                }

                if radar.metadata == nil {
                    OpenRadarAPI().fetchRadar(by: radar.id) { (result) in
                        switch result {
                        case .value(let radar):
                            RadarCollection.shared.upsert(radar: radar)
                            try? RadarCollection.shared.updatedViewed(radarID: radar.id)
                        case .error(let error):
                            print(error.localizedDescription)
                            try? RadarCollection.shared.updatedViewed(radarID: radar.id)
                        }
                    }
                } else {
                    try? RadarCollection.shared.updatedViewed(radarID: radar.id)
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
