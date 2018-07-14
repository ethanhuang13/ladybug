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
    private let searchController = UISearchController(searchResultsController: nil)
    private var previewingContext: UIViewControllerPreviewing?

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
        previewingContext = registerForPreviewing(with: tableViewViewModel, sourceView: view)

        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter radars with text".localized()
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        tabBarController?.definesPresentationContext = true

        RadarCollection.shared.delegates.add(delegate: self)
    }

    func reloadData() {
        let isAPIKeySet = OpenRadarKeychain.getAPIKey() != nil
        let setupAPIKeySubtitle = "(Setup Open Radar API Key for more information)".localized()

        let radars = RadarCollection.shared.bookmarks(sortBy: UserDefaults.standard.sortOption)
        let filteredRadars: [Radar] = {
            if let searchText = searchController.searchBar.text?.lowercased(),
                searchText.isEmpty != true {
                return radars.filter { $0.caseInsensitiveContains(string: searchText) }
            } else {
                return radars
            }
        }()

        let cells = filteredRadars.map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: isAPIKeySet ? radar.cellSubtitle : setupAPIKeySubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: nil, previewingViewController: {

                switch UserDefaults.standard.browserOption {
                case .native, .briskApp:
                    return DetailViewController(radar: radar)
                case .sfvcReader, .sfvc, .safari:
                    return (self.tabBarController as? TabBarController)?.safariViewController(url: radar.number.url(by: .openRadar), readerMode: UserDefaults.standard.browserOption == .sfvcReader)
                }
            }, selectAction: {
                RadarURLOpener.shared.open(radar.number, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                }

                if radar.metadata == nil {
                    OpenRadarAPI().fetchRadar(by: radar.number) { (result) in
                        switch result {
                        case .value(let radar):
                            _ = RadarCollection.shared.upsert(radar: radar)
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

extension BookmarksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadData()
    }
}

extension BookmarksViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            unregisterForPreviewing(withContext: context)
            previewingContext = searchController.registerForPreviewing(with: tableViewViewModel, sourceView: self.view)
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            searchController.unregisterForPreviewing(withContext: context)
            previewingContext = registerForPreviewing(with: tableViewViewModel, sourceView: self.view)
        }
    }
}
