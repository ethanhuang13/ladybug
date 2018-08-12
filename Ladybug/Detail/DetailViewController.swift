//
//  DetailViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/7/14.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController, TableViewControllerUsingViewModel {
    var radar: Radar {
        didSet {
            self.reloadData()
        }
    }

    init(radar: Radar) {
        self.radar = radar
        super.init(style: .grouped)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tableViewViewModel: TableViewViewModel = { TableViewViewModel(tableViewController: self) }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = radar.number.string

        tableView.dataSource = tableViewViewModel
        tableView.delegate = tableViewViewModel

        reloadData()

        OpenRadarAPI().fetchRadar(by: radar.number) { [weak self] (result) in
            switch result {
            case .value(let radar):
                if RadarCollection.shared.upsert(radar: radar) {
                    self?.radar = radar
                    RadarCollection.shared.forceNotifyDelegates()
                }
            case .error(_):
                break
            }
        }

        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = radar.number.url(by: .openRadar)
        self.userActivity = userActivity
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.userActivity?.becomeCurrent()
    }

    func reloadData() {
        /*
         Ladybug Layout


         ---
         Open Radar Layout
         Title
         Originator
         Number             Date Originated
         Status             Resolved
         Product            Product Version
         Classification     Reproducible
         Description

         ---
         Brisk iOS Layout
         Product
         Area
         Version
         Classification
         Reproducibility
         Configuration
         Title
         Description
         Steps
         Expected
         Actual
         Notes
         Attachment
         */

        DispatchQueue.main.async {
            let radar = self.radar
            var sections: [TableViewSectionViewModel] = []

            let titleCellViewModel = TableViewCellViewModel(title: radar.metadata?.title ?? "(No record on Open Radar)".localized(), selectionStyle: .none, accessoryType: .none, selectAction: { })
            let titleSection = TableViewSectionViewModel(header: radar.number.string, footer: nil, rows: [titleCellViewModel])
            sections.append(titleSection)

            if let metadata = radar.metadata {
                let pairs: [(String, String)] = [
                    ("Product", metadata.product),
                    ("Product Version", metadata.productVersion),
                    ("Classification", metadata.classification),
                    ("Reproducibility", metadata.reproducible),
                    ("Status", metadata.status),
                    ("Originated", metadata.originated),
                    ("Resolved", metadata.resolved),
                    //                (metadata.user, "User")
                ]
                let metadataCells = pairs.map {
                    return TableViewCellViewModel(title: $0.0, subtitle: $0.1, cellStyle: .value1, selectionStyle: .none, accessoryType: .none, selectAction: { })
                }
                let metadataSection = TableViewSectionViewModel(header: nil, footer: nil, rows: metadataCells)
                sections.append(metadataSection)

                let descriptionCellViewModel = TableViewCellViewModel(textViewString: metadata.description)
                let descriptionSection = TableViewSectionViewModel(header: nil, footer: nil, rows: [descriptionCellViewModel])
                sections.append(descriptionSection)
            }

            var actionRows: [TableViewCellViewModel] = []
            let rdarURLString = radar.number.rdarURLString
            actionRows.append(TableViewCellViewModel(title: "Copy link".localized(), subtitle: rdarURLString, cellStyle: .subtitle, selectAction: {
                self.copyRdarLink()
            }))
            let openRadarURLString = radar.number.url(by: .openRadar).absoluteString
            actionRows.append(TableViewCellViewModel(title: "Copy link".localized(), subtitle: openRadarURLString, cellStyle: .subtitle, selectAction: {
                self.copyOpenRadarLink()
            }))
            actionRows.append(TableViewCellViewModel(title: "Open in-app browser".localized(), selectAction: {
                self.openInSafariViewController()
            }))
            actionRows.append(TableViewCellViewModel(title: "Open in Safari".localized(), selectAction: {
                self.openInSafari()
            }))
            if RadarURLOpener.shared.canOpen(in: .briskApp) {
                actionRows.append(TableViewCellViewModel(title: "Duplicate in Brisk".localized(), subtitle: nil, selectAction: {
                    self.duplicateInBrisk()
                }))
            }
            let actionSection = TableViewSectionViewModel(header: "Actions".localized(), footer: nil, rows: actionRows)
            sections.append(actionSection)

            self.tableViewViewModel.sections = sections

            self.navigationItem.title = radar.number.string
            self.tableView.reloadData()
        }
    }

    func load(radar: Radar) {
        self.radar = radar
        
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    override var previewActionItems: [UIPreviewActionItem] {
        var items: [UIPreviewActionItem] = []

        let copyRdarLinkAction = UIPreviewAction(title: String(format: "Copy %@".localized(), radar.number.rdarURLString), style: .default) { (_, _) in
            self.copyRdarLink()
        }
        let copyOpenRadarLinkAction = UIPreviewAction(title: "Copy Open Radar link".localized(), style: .default) { (_, _) in
            self.copyOpenRadarLink()
        }
        let openInSafariViewControllerAction = UIPreviewAction(title: "Open in-app browser".localized(), style: .default) { (_, _) in
            self.openInSafariViewController()
        }
        let openInSafariAction = UIPreviewAction(title: "Open in Safari".localized(), style: .default) { (_, _) in
            self.openInSafari()
        }
        let duplicateInBrisk = UIPreviewAction(title: "Duplicate in Brisk".localized(), style: .default) { (_, _) in
            self.duplicateInBrisk()
        }

        items = [copyRdarLinkAction, copyOpenRadarLinkAction, openInSafariViewControllerAction, openInSafariAction]

        if RadarURLOpener.shared.canOpen(in: .briskApp) {
            items.append(duplicateInBrisk)
        }
        return items
    }

    // MARK: - Actions

    private func copyRdarLink() {
        let rdarURLString = radar.number.rdarURLString
        UIPasteboard.general.string = rdarURLString
    }

    private func copyOpenRadarLink() {
        let openRadarURLString = radar.number.url(by: .openRadar).absoluteString
        UIPasteboard.general.string = openRadarURLString
    }

    private func openInSafariViewController() {
        RadarURLOpener.shared.open(radar.number, radarOption: .openRadar, in: .sfvcReader, completion: { (_) in
        })
    }

    private func openInSafari() {
        RadarURLOpener.shared.open(radar.number, radarOption: .openRadar, in: .safari, completion: { (_) in
        })
    }

    private func duplicateInBrisk() {
        RadarURLOpener.shared.open(radar.number, radarOption: .brisk, in: .briskApp, completion: { (_) in
        })
    }
}
