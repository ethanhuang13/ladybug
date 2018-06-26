//
//  TabBarController.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/21.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import SafariServices

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setNeedsStatusBarAppearanceUpdate()

        tabBar.barTintColor = .barTintColor

        let vcs = [
            UINavigationController(rootViewController: HistoryViewController(style: .plain)),
            UINavigationController(rootViewController: BookmarksViewController(style: .plain)),
            UINavigationController(rootViewController: SettingsViewController(style: .grouped))]

        viewControllers = vcs

        vcs.forEach({ (vc) in
            _ = vc.viewControllers.first?.view.description // Preload each view controllers
        })

        tabBar.isHidden = vcs.count <= 1

        RadarURLOpener.shared.delegate = self
    }
}

extension TabBarController: RadarURLOpenerUI {
    func openRadarLinkInSafariViewController(_ radarID: RadarID, radarOption: RadarOption, readerMode: Bool) {
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
        sfvc.preferredControlTintColor = .tintColor

        self.tabBarController?.selectedIndex = 0

        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(sfvc, animated: UIApplication.shared.applicationState == .active, completion: nil)
            }
        } else {
            self.present(sfvc, animated: UIApplication.shared.applicationState == .active, completion: nil)
        }
    }
}
