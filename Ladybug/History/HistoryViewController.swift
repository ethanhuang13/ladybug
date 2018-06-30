//
//  HistoryViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController, TableViewControllerUsingViewModel {
    lazy var dataSourceDelegate: TableViewDataSourceDelegate = { TableViewDataSourceDelegate(tableViewController: self) }()

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

        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate

        reloadData()
        RadarCollection.shared.delegates.add(delegate: self)
    }

    @objc func add() {
        let alertController = UIAlertController(title: "Add a Radar".localized(), message: "Enter radar number or url".localized(), preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "12345678"
        }
        alertController.addAction(UIAlertAction(title: "Add".localized(), style: .default, handler: { (_) in
            guard let text = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            let radarIDOptional: RadarID? = {
                if let url = URL(string: text),
                    let radarID = RadarID(url: url) {
                    return radarID
                } else if let radarID = RadarID(string: text) {
                    return radarID
                } else {
                    return nil
                }
            }()

            let opener = RadarURLOpener.shared
            if let radarID = radarIDOptional,
                opener.canOpen(in: UserDefaults.standard.browserOption) {
                OpenRadarAPI().fetchRadar(by: radarID) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .value(let radar):
                            RadarCollection.shared.upsert(radar: radar)
                            try? RadarCollection.shared.updatedViewed(radarID: radar.id)

                            opener.open(radarID, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
                            }
                        case .error(let error):
                            self.present(UIAlertController.errorAlertController(error), animated: true, completion: { })
                        }
                    }
                }
            } else {
                self.present(UIAlertController.errorAlertController(RadarURLParserError.noValidRadarNumber), animated: true, completion: { })
            }
        }))
        alertController.addAction(.cancelAction)

        present(alertController, animated: true) { }
    }

    func reloadData() {
        let cells = RadarCollection.shared.history().map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: radar.cellSubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: UISwipeActionsConfiguration(actions: [radar.removeFromHistoryAction]), previewingViewController: {
                let url = radar.id.url(by: .openRadar)
                return (self.tabBarController as? TabBarController)?.safariViewController(url: url, readerMode: UserDefaults.standard.browserOption == .sfvcReader)
            }, selectAction: {
                RadarURLOpener.shared.open(radar.id, radarOption: UserDefaults.standard.radarOption,  in: UserDefaults.standard.browserOption) { (result) in
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

extension HistoryViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}
