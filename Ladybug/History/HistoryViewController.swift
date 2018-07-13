//
//  HistoryViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController, TableViewControllerUsingViewModel {
    lazy var tableViewViewModel: TableViewViewModel = { TableViewViewModel(tableViewController: self) }()
    private let searchController = UISearchController(searchResultsController: nil)
    private var previewingContext: UIViewControllerPreviewing?

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

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))

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

        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardDidChange), name: .UIPasteboardChanged, object: nil)
    }

    @objc func pasteboardDidChange() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    @objc func add() {
        guard OpenRadarKeychain.getAPIKey() != nil else {
            OpenRadarKeychain.presentSetupAlertController(on: self) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.reloadData()
                        RadarCollection.shared.forceNotifyDelegates()
                    }
                }
            }
            return
        }

        let alertController = UIAlertController(title: "Add a Radar".localized(), message: "Enter radar number or url".localized(), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "12345678"
        }
        alertController.addAction(UIAlertAction(title: "Add".localized(), style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            let opener = RadarURLOpener.shared
            if let radarNumber = RadarNumber(string: text),
                opener.canOpen(in: UserDefaults.standard.browserOption) {
                OpenRadarAPI().fetchRadar(by: radarNumber) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .value(let radar):
                            RadarCollection.shared.upsert(radar: radar)
                            try? RadarCollection.shared.updatedViewed(radarNumber: radar.number)

                            opener.open(radarNumber, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                            }
                        case .error(let error):
                            self.present(UIAlertController.errorAlertController(error), animated: true, completion: { })
                        }
                    }
                }
            } else {
                self.present(UIAlertController.errorAlertController(RadarURLParseError.noValidRadarNumber), animated: true, completion: { })
            }
        }))
        alertController.addAction(.cancelAction)

        present(alertController, animated: true) { }
    }

    func reloadData() {
        var sections: [TableViewSectionViewModel] = []

        if let pasteboardString = UIPasteboard.general.string,
            let radarNumber = RadarNumber(string: pasteboardString) {
            let cell = TableViewCellViewModel(title: radarNumber.string, subtitle: String(format: "Tap to add from clipboard: %@".localized(), pasteboardString), cellStyle: .subtitle, previewingViewController: {
                let url = radarNumber.url(by: .openRadar)
                return (self.tabBarController as? TabBarController)?.safariViewController(url: url, readerMode: UserDefaults.standard.browserOption == .sfvcReader)
            }, selectAction: {
                RadarURLOpener.shared.open(radarNumber, radarOption: UserDefaults.standard.radarOption,  in: UserDefaults.standard.browserOption) { (result) in
                }

                if RadarCollection.shared.radar(radarNumber)?.metadata == nil {
                    OpenRadarAPI().fetchRadar(by: radarNumber) { (result) in
                        switch result {
                        case .value(let radar):
                            RadarCollection.shared.upsert(radar: radar)
                            try? RadarCollection.shared.updatedViewed(radarNumber: radar.number)
                        case .error(let error):
                            print(error.localizedDescription)
                            try? RadarCollection.shared.updatedViewed(radarNumber: radarNumber)
                        }
                    }
                } else {
                    try? RadarCollection.shared.updatedViewed(radarNumber: radarNumber)
                }
            })

            let section = TableViewSectionViewModel(header: "Clipboard".localized(), footer: nil, rows: [cell])
            sections.append(section)
        }

        let isAPIKeySet = OpenRadarKeychain.getAPIKey() != nil
        let setupAPIKeySubtitle = "(Setup Open Radar API Key for more information)".localized()

        let radars = RadarCollection.shared.history()
        let filteredRadars: [Radar] = {
            if let searchText = searchController.searchBar.text?.lowercased(),
                searchText.isEmpty != true {
                return radars.filter { $0.caseInsensitiveContains(string: searchText) }
            } else {
                return radars
            }
        }()

        let cells = filteredRadars.map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: isAPIKeySet ? radar.cellSubtitle : setupAPIKeySubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: UISwipeActionsConfiguration(actions: [radar.removeFromHistoryAction]), previewingViewController: {
                let url = radar.number.url(by: .openRadar)
                return (self.tabBarController as? TabBarController)?.safariViewController(url: url, readerMode: UserDefaults.standard.browserOption == .sfvcReader)
            }, selectAction: {
                RadarURLOpener.shared.open(radar.number, radarOption: UserDefaults.standard.radarOption,  in: UserDefaults.standard.browserOption) { (result) in
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

        let mainSection = TableViewSectionViewModel(header: sections.isEmpty ? nil : "History".localized(), footer: nil, rows: cells)
        sections.append(mainSection)

        tableViewViewModel.sections = sections
        tableView.reloadData()
    }
}

extension HistoryViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}

extension HistoryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadData()
    }
}

extension HistoryViewController: UISearchControllerDelegate {
    // To support 3D Touch Peek & Pop in UISearchController, the solution is here https://stackoverflow.com/a/42261971/2627067
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
