//
//  SettingsViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import Echo

class SettingsViewController: UITableViewController, TableViewControllerUsingViewModel {
    lazy var tableViewViewModel: TableViewViewModel = { TableViewViewModel(tableViewController: self) }()

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

        tableView.dataSource = tableViewViewModel
        tableView.delegate = tableViewViewModel

        reloadData()
    }

    func reloadData() {
        DispatchQueue.main.async {
            self.tableViewViewModel.sections =
                [self.linksSection,
                 self.viewSection,
                 self.dataSection,
                 self.aboutSection]

            self.tableView.reloadData()
        }
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
            TableViewCellViewModel(title: "Viewing/Browser".localized(), subtitle: UserDefaults.standard.browserOption.title, cellStyle: .subtitle, selectAction: {

                let alertController = UIAlertController(title: "Viewing/Browser".localized(), message: nil, preferredStyle: .alert)

                let browserOptions: [BrowserOption] = UserDefaults.standard.radarOption.possibleBrowserOptions
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

        let openRadarAPIKeyViewModel = TableViewCellViewModel(title: "Open Radar API Key".localized(), subtitle: "Setup or remove the API Key".localized(), cellStyle: .subtitle, selectAction: {

            if OpenRadarKeychain.getAPIKey() != nil {
                OpenRadarKeychain.presentRemoveKeyAlertContrller(on: self, completion: { (success) in
                    if success {
                        self.reloadData()
                        RadarCollection.shared.forceNotifyDelegates()
                    }
                })
            } else {
                OpenRadarKeychain.presentSetupAlertController(on: self, completion: { (success) in
                    if success {
                        self.reloadData()
                        RadarCollection.shared.forceNotifyDelegates()
                    }
                })
            }
        })

        let rows: [TableViewCellViewModel] = {
            if UserDefaults.standard.radarOption == .brisk {
                return [radarOptionCellViewModel, openRadarAPIKeyViewModel]
            } else {
                return [radarOptionCellViewModel, browserOptionCellViewModel, openRadarAPIKeyViewModel]
            }
        }()

        let sectionViewModel =
            TableViewSectionViewModel(header: "Opening Radar Links".localized(),
                                      footer: nil,
                                      rows: rows)

        return sectionViewModel
    }

    private var viewSection: TableViewSectionViewModel {
        let sortOptionCellViewModel = TableViewCellViewModel(title: "Sorting".localized(), subtitle: String(format: "Sort bookmarks by %@".localized(), UserDefaults.standard.sortOption.title), cellStyle: .subtitle) {
            let alertController = UIAlertController(title: "Sorting".localized(), message: "Sort bookmarks by?".localized(), preferredStyle: .alert)

            for option in [SortOption.radarNumber, .addedDate] {
                alertController.addAction(UIAlertAction(title: option.title, style: .default, handler: { (_) in
                    UserDefaults.standard.sortOption = option
                    RadarCollection.shared.forceNotifyDelegates()
                    self.reloadData()
                }))
            }

            alertController.addAction(.cancelAction)
            self.present(alertController, animated: true, completion: { })
        }

        return TableViewSectionViewModel(header: "View".localized(), footer: nil, rows: [sortOptionCellViewModel])
    }

    private var dataSection: TableViewSectionViewModel {
        let importCellViewModel = TableViewCellViewModel(title: "Import from Open Radar".localized()) {
            guard OpenRadarKeychain.getAPIKey() != nil else {
                OpenRadarKeychain.presentSetupAlertController(on: self, completion: { (success) in
                    if success {
                        self.reloadData()
                        RadarCollection.shared.forceNotifyDelegates()
                    }
                })
                return
            }

            let alertController = UIAlertController(title: "Import from Open Radar".localized(), message: "Enter an Open Radar username.".localized(), preferredStyle: .alert)

            alertController.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .emailAddress
                textField.textContentType = .emailAddress
                textField.placeholder = "myname@company.com"
                textField.delegate = self
            })
            alertController.addAction(UIAlertAction(title: "Import".localized(), style: .default, handler: { (_) in
                guard let email = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }


                UIApplication.shared.isNetworkActivityIndicatorVisible = true // No use on iPhone X yet
                OpenRadarAPI().fetchRadarsBy(user: email, completion: { (result) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        switch result {
                        case .value(let value):
                            let radars = value.reversed()
                            radars.forEach {
                                $0.bookmarkedDate = Date()
                            }
                            let radarsDict: [RadarNumber: Radar] = radars.reduce(into: [RadarNumber: Radar]()) {
                                $0[$1.number] = $1
                            }
                            RadarCollection.shared.merge(radars: radarsDict)

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
                presentExportActivityController(title: "Bookmarks".localized(), radars: RadarCollection.shared.bookmarks(sortBy: UserDefaults.standard.sortOption))
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

        let restoreCellViewModel = TableViewCellViewModel(title: "Import from a JSON File".localized(), subtitle: "Merge or replace".localized(), cellStyle: .subtitle) {
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

                let alertController = UIAlertController(title: "Merge or Replace?".localized(), message: String(format: "Loaded %li radars, do you want to merge or replace current radars? This operation cannot be undone.".localized(), radars.count), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Merge".localized(), style: .default, handler: { (_) in
                    RadarCollection.shared.merge(radars: radars)
                    RadarCollection.shared.archive()

                    let alertController = UIAlertController(title: "Import Finished".localized(), message: String(format: "Merged %li radars from the JSON file".localized(), radars.count), preferredStyle: .alert)
                    alertController.addAction(.okAction)
                    self.present(alertController, animated: true) { }
                }))
                alertController.addAction(UIAlertAction(title: "Replace".localized(), style: .destructive, handler: { (_) in
                    RadarCollection.shared.replaceAll(radars: radars)
                    RadarCollection.shared.archive()

                    let alertController = UIAlertController(title: "Import Finished".localized(), message: String(format: "Replaced with %li radars from the JSON file".localized(), radars.count), preferredStyle: .alert)
                    alertController.addAction(.okAction)
                    self.present(alertController, animated: true) { }
                }))

                alertController.addAction(.cancelAction)
                self.present(alertController, animated: true) { }
            } catch {
                self.present(UIAlertController.errorAlertController(error), animated: true, completion: { })
            }
        } else {
            print("No valid file")
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.textContentType == .emailAddress,
            textField.text?.isEmpty == true,
            string.hasPrefix("mailto:") {
            textField.text = string.replacingOccurrences(of: "mailto:", with: "")
            return false
        } else {
            return true
        }
    }
}
