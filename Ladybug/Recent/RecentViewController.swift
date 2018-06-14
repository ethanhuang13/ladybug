//
//  RecentViewController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import SafariServices

class RecentViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Recent".localized()

        RadarURLOpener.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RecentViewController: RadarURLOpenerUI {
    func openRadarInSafariViewController(_ radarID: RadarID, radarOption: RadarOption, readerMode: Bool) {
        // TODO: Prepend radarID to self.array

        let url = radarID.url(by: radarOption)
        presentSafariViewController(url: url, readerMode: readerMode)
    }

    private func presentSafariViewController(url: URL, readerMode: Bool) {
        let sfvc: SFSafariViewController = {
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.barCollapsingEnabled = false
                config.entersReaderIfAvailable = readerMode

                return SFSafariViewController(url: url, configuration: config)
            } else {
                return SFSafariViewController(url: url, entersReaderIfAvailable: readerMode)
            }
        }()

        sfvc.preferredBarTintColor = .barTintColor

        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(sfvc, animated: false, completion: nil)
            }
        } else {
            self.present(sfvc, animated: false, completion: nil)
        }
    }
}
