//
//  BookmarksViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController, TableViewControllerUsingViewModel {
    lazy var tableViewViewModel: TableViewViewModel = { TableViewViewModel(tableViewController: self) }()

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

        tableView.dataSource = tableViewViewModel
        tableView.delegate = tableViewViewModel

        RadarCollection.shared.delegates.add(delegate: self)
    }

    func reloadData() {
        let isAPIKeySet = OpenRadarKeychain.getAPIKey() != nil
        let setupAPIKeySubtitle = "(Setup Open Radar API Key for more information)".localized()

        let cells = RadarCollection.shared.bookmarks().map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: isAPIKeySet ? radar.cellSubtitle : setupAPIKeySubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: nil, previewingViewController: {
                let url = radar.number.url(by: .openRadar)
                return (self.tabBarController as? TabBarController)?.safariViewController(url: url, readerMode: UserDefaults.standard.browserOption == .sfvcReader)
            }, selectAction: {
                RadarURLOpener.shared.open(radar.number, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                }

                if radar.metadata == nil {
                    OpenRadarAPI().fetchRadar(by: radar.number) { (result) in
                        switch result {
                        case .value(let radar):
                            RadarCollection.shared.upsert(radar: radar)
                            try? RadarCollection.shared.updatedViewed(radarNumber: radar.number)
                        case .error(let error):
                            print(error.localizedDescription)
                            try? RadarCollection.shared.updatedViewed(radarNumber: radar.number)
                        }
                    }
                } else {
                    try? RadarCollection.shared.updatedViewed(radarNumber: radar.number)
                }
            })
        }

        let section = TableViewSectionViewModel(header: nil, footer: nil, rows: cells)
        tableViewViewModel.sections = [section]
        tableView.reloadData()
    }
}

extension BookmarksViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}
