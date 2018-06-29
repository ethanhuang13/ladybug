//
//  AppDelegate.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/10.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = TabBarController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        UIView.appearance().tintColor = .tintColor

        RadarCollection.shared.unarchive()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        RadarCollection.shared.archive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - URL Scheme

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        let opener = RadarURLOpener.shared

        if let radarID = RadarID(url: url),
            opener.canOpen(in: UserDefaults.standard.browserOption) {
            opener.open(radarID, radarOption: UserDefaults.standard.radarOption, in: UserDefaults.standard.browserOption) { (result) in
            }

            OpenRadarAPI().fetchRadar(by: radarID) { (result) in
                switch result {
                case .value(let radar):
                    RadarCollection.shared.upsert(radar: radar)
                case .error(let error):
                    print(error.localizedDescription)
                    let radar = Radar(id: radarID)
                    RadarCollection.shared.upsert(radar: radar)
                }
            }

            return true
        } else {
            return false
        }
    }
}
