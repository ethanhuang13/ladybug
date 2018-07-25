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
    func openRadarInDetailViewController(_ radar: Radar) {

        DispatchQueue.main.async {
            let vc = DetailViewController(radar: radar)
            
            if let navController = self.selectedViewController as? UINavigationController {
                if let vc = navController.topViewController as? DetailViewController {
                    vc.radar = radar
                } else {
                    navController.pushViewController(vc, animated: true)
                }
            }
        }
    }

    func openRadarLinkInSafariViewController(_ radarNumber: RadarNumber, radarOption: RadarOption, readerMode: Bool) {
        let url = radarNumber.url(by: radarOption)
        let sfvc = safariViewController(url: url, readerMode: readerMode)

        self.tabBarController?.selectedIndex = 0

        if let presented = self.presentedViewController {
            presented.dismiss(animated: false) {
                self.present(sfvc, animated: UIApplication.shared.applicationState == .active, completion: nil)
            }
        } else {
            self.present(sfvc, animated: UIApplication.shared.applicationState == .active, completion: nil)
        }
    }

    func safariViewController(url: URL, readerMode: Bool) -> SFSafariViewController {
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

        sfvc.delegate = self
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = url
        sfvc.userActivity = userActivity

        return sfvc
    }
}

extension TabBarController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully {
            controller.userActivity?.becomeCurrent()
        }
    }
}
