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

        tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 0)

        navigationController?.navigationBar.barTintColor = .barTintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.tintColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.tintColor]
        }
        navigationItem.title = "Settings".localized()

        tableView.dataSource = dataSourceDelegate
        tableView.delegate = dataSourceDelegate

        reloadData()
    }

    func reloadData() {
        dataSourceDelegate.viewModel = TableViewViewModel(sections:
            [linksSection,
//             dataSection,
//             donationSection,
             aboutSection])

        tableView.reloadData()
    }
}

extension SettingsViewController {
    private var linksSection: TableViewSectionViewModel {
        let radarOptionCellViewModel =
            TableViewCellViewModel(title: "Radar Website/App".localized(), subtitle: UserDefaults.standard.radarOption.title, cellStyle: .subtitle, selectAction: {

                let alertController = UIAlertController(title: "Radar Website/App".localized(), message: nil, preferredStyle: .alert)

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
            TableViewCellViewModel(title: "Browser".localized(), subtitle: UserDefaults.standard.browserOption.title, cellStyle: .subtitle, selectAction: {

                let alertController = UIAlertController(title: "Browser".localized(), message: nil, preferredStyle: .alert)

                let browserOptions: [BrowserOption] = [.sfvcReader, .sfvc, .safari]
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

        let rows: [TableViewCellViewModel] = {
            if UserDefaults.standard.radarOption == .brisk {
                return [radarOptionCellViewModel]
            } else {
                return [radarOptionCellViewModel, browserOptionCellViewModel]
            }
        }()

        let sectionViewModel =
            TableViewSectionViewModel(header: "Opening Radar Links".localized(),
                                      footer: nil,
                                      rows: rows)

        return sectionViewModel
    }

    private var dataSection: TableViewSectionViewModel {
        let clearHistoryCellViewModel = TableViewCellViewModel(title: "Clear History".localized()) {

        }

        let exportBookmarksCellViewModel = TableViewCellViewModel(title: "Export Bookmarks".localized()) {

        }

        let sectionViewModel = TableViewSectionViewModel(header: "Data".localized(), footer: nil, rows: [clearHistoryCellViewModel, exportBookmarksCellViewModel])
        return sectionViewModel
    }

    private var donationSection: TableViewSectionViewModel {
        let donateCellViewModel = TableViewCellViewModel(title: "Donate".localized(), subtitle: "Buy me some coffee".localized(), cellStyle: .subtitle) {

        }

        let sectionViewModel = TableViewSectionViewModel(header: "Donation".localized(), footer: nil, rows: [donateCellViewModel])
        return sectionViewModel
    }

    private var aboutSection: TableViewSectionViewModel {
        let rateCellViewModel = TableViewCellViewModel(title: "App Store".localized()) {
            UIApplication.shared.open(AppConstants.appStoreURL, options: [:], completionHandler: nil)
        }

        let feedbackCellViewModel = TableViewCellViewModel(title: "Feedback".localized()) {
            self.presentFeedbackMailComposer()
        }

        let developerCellViewModel = TableViewCellViewModel(title: "Developer".localized(), subtitle: "@ethanhuang13", cellStyle: .value1) {
            UIApplication.shared.open(AppConstants.developerURL, options: [:], completionHandler: nil)
        }

        let githubCellViewModel = TableViewCellViewModel(title: "GitHub".localized(), subtitle: nil) {

            UIApplication.shared.open(AppConstants.githubURL, options: [:], completionHandler: nil)
        }

        let sectionViewModel = TableViewSectionViewModel(header: "About".localized(), footer: AppConstants.aboutString, rows: [rateCellViewModel, feedbackCellViewModel, developerCellViewModel, githubCellViewModel])
        return sectionViewModel
    }
}
