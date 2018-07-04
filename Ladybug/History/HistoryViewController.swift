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

        RadarCollection.shared.delegates.add(delegate: self)

        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardDidChange), name: .UIPasteboardChanged, object: nil)
    }

    @objc func pasteboardDidChange() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    @objc func add() {
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
                self.present(UIAlertController.errorAlertController(RadarURLParserError.noValidRadarNumber), animated: true, completion: { })
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

        let cells = RadarCollection.shared.history().map { (radar) -> TableViewCellViewModel in
            TableViewCellViewModel(title: radar.cellTitle, subtitle: radar.cellSubtitle, cellStyle: .subtitle, leadingSwipeActions: UISwipeActionsConfiguration(actions: [radar.toggleBookmarkAction]), trailingSwipeActions: UISwipeActionsConfiguration(actions: [radar.removeFromHistoryAction]), previewingViewController: {
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

        dataSourceDelegate.viewModel = TableViewViewModel(sections: sections)
        tableView.reloadData()
    }
}

extension HistoryViewController: RadarCollectionDelegate {
    func radarCollectionDidUpdate() {
        reloadData()
    }
}
