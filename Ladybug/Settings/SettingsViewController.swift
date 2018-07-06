//
//  SettingsViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    lazy var dataSourceDelegate: TableViewDataSourceDelegate =  { TableViewDataSourceDelegate(tableViewController: self) }()

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
             dataSection,
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
        let importCellViewModel = TableViewCellViewModel(title: "Import from Open Radar".localized()) {
            let alertController = UIAlertController(title: "Import from Open Radar".localized(), message: "Enter an Open Radar username.\n\nThe email will not be collected.".localized(), preferredStyle: .alert)

            alertController.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .emailAddress
                textField.textContentType = .emailAddress
                textField.placeholder = "myname@company.com"
            })
            alertController.addAction(UIAlertAction(title: "Import".localized(), style: .default, handler: { (_) in
                guard let email = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

                OpenRadarAPI().fetchRadarsBy(user: email, completion: { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .value(let value):
                            let radars = value.reversed()
                            radars.forEach {
                                RadarCollection.shared.upsert(radar: $0)
                            }
                            RadarCollection.shared.bookmark(radarNumbers: radars.map { $0.number } )

                            let alertController = UIAlertController(title: "Import Finished".localized(), message: String(format: "Imported %li radars from Open Radar".localized(), radars.count), preferredStyle: .alert)
                            alertController.addAction(.okAction)
                            self.present(alertController, animated: true) { }
                        case .error(let error):
                            let alertController = UIAlertController(title: "Import Failed".localized(), message: error.localizedDescription, preferredStyle: .alert)
                            alertController.addAction(.cancelAction)
                            self.present(alertController, animated: true) { }
                        }
                    }
                })
            }))

            alertController.addAction(.cancelAction)

            self.present(alertController, animated: true) { }
        }

        let exportCellViewModel = TableViewCellViewModel(title: "Export Markdown...".localized()) {
            let alertController = UIAlertController(title: "Export Markdown...".localized(), message: "Select what to export".localized(), preferredStyle: .alert)

            func presentExportActivityController(title: String, radars: [Radar]) {
                let radarString = radars.map ({ "* [\($0.number.rdarURLString)](\($0.number.url(by: .openRadar))) \($0.cellSubtitle)" }).joined(separator: "\n")
                let string = "# Ladybug \(title)\n\n\(radarString)"

                let avc = UIActivityViewController(activityItems: [string], applicationActivities: nil)
                avc.completionWithItemsHandler = { activity, success, items, error in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                }

                avc.modalPresentationStyle = .popover
                let popPC = avc.popoverPresentationController

                if let sourceView = self.tabBarController?.tabBar {
                    popPC?.sourceView = sourceView
                    popPC?.sourceRect = sourceView.bounds
                }

                self.present(avc, animated: true) { }
            }

            alertController.addAction(UIAlertAction(title: "History".localized(), style: .default, handler: { (_) in
                presentExportActivityController(title: "History".localized(), radars: RadarCollection.shared.history())
            }))
            alertController.addAction(UIAlertAction(title: "Bookmarks".localized(), style: .default, handler: { (_) in
                presentExportActivityController(title: "Bookmarks".localized(), radars: RadarCollection.shared.bookmarks())
            }))
            alertController.addAction(.cancelAction)

            self.present(alertController, animated: true) { }
        }

        let backupCellViewModel = TableViewCellViewModel(title: "Backup as a JSON File".localized()) {
            RadarCollection.shared.archive()
            let url = RadarCollection.shared.fileURL
            guard FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            let vc = UIDocumentPickerViewController(url: url, in: .exportToService)
            vc.delegate = self
            self.present(vc, animated: true) { }
        }

        let restoreCellViewModel = TableViewCellViewModel(title: "Restore from a JSON File".localized()) {
            let vc = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
            vc.allowsMultipleSelection = false
            vc.delegate = self
            self.present(vc, animated: true) { }
        }

        let sectionViewModel = TableViewSectionViewModel(header: "Data".localized(), footer: "Ladybug doesn't sync, but".localized(), rows: [importCellViewModel, exportCellViewModel, backupCellViewModel, restoreCellViewModel])
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

extension SettingsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import else {
            return
        }

        // Restore from JSON
        if let url = urls.first,
            url.isFileURL {
            do {
                let radars = try RadarCollection.load(from: url)
                radars.values.forEach {
                    RadarCollection.shared.upsert(radar: $0)
                }
                RadarCollection.shared.archive()
                RadarCollection.shared.forceNotifyDelegates()

                let alertController = UIAlertController(title: "Import Finished".localized(), message: String(format: "Imported %li radars from the JSON file".localized(), radars.count), preferredStyle: .alert)
                alertController.addAction(.okAction)
                self.present(alertController, animated: true) { }
            } catch {
                self.present(UIAlertController.errorAlertController(error), animated: true, completion: { })
            }
        } else {
            print("No valid file")
        }
    }
}
