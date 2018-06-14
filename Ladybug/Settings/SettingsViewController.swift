//
//  SettingsViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    let dataSourceDelegate = TableViewDataSourceDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings".localized()

        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate

        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {
        let radarOptionCellViewModel =
            TableViewCellViewModel(title: "Radar".localized(), subtitle: UserDefaults.standard.radarOption.title, cellStyle: .value1, selectAction: {

                let alertController = UIAlertController(title: "Radar Option".localized(), message: "Open a Radar link on...".localized(), preferredStyle: .alert)

                var radarOptions: [RadarOption] = [.openRadar, .appleRadar]
                if RadarURLOpener.shared.canOpen(in: .briskApp) {
                    radarOptions.append(.brisk)
                }

                radarOptions.forEach({ (radarOption) in
                    alertController.addAction(UIAlertAction(title: radarOption.title, style: .default, handler: { (_) in
                        UserDefaults.standard.radarOption = radarOption
                        self.reloadData()
                    }))
                })

                alertController.addAction(.cancelAction)
                self.present(alertController, animated: true, completion: { })
            })

        let browserOptionCellViewModel =
            TableViewCellViewModel(title: "Browser".localized(), subtitle: UserDefaults.standard.browserOption.title, cellStyle: .value1, selectAction: {

                let alertController = UIAlertController(title: "Browser Option".localized(), message: "Open a Radar link in...".localized(), preferredStyle: .alert)

                let browserOptions: [BrowserOption] = [.sfvcReader, .sfvc, .safari, .briskApp]
                browserOptions.forEach { (browserOption) in
                    if RadarURLOpener.shared.canOpen(in: browserOption) {
                        alertController.addAction(UIAlertAction(title: browserOption.title, style: .default, handler: { (_) in
                            UserDefaults.standard.browserOption = browserOption
                            self.reloadData()
                        }))
                    }
                }

                alertController.addAction(.cancelAction)
                self.present(alertController, animated: true, completion: { })
            })

        let defaultSection =
            TableViewSectionViewModel(header: "Open a Radar Link".localized(),
                                      footer: nil,
                                      rows: [radarOptionCellViewModel, browserOptionCellViewModel])

        dataSourceDelegate.viewModel = TableViewViewModel(sections: [defaultSection])

        self.tableView.reloadData()
    }
}
