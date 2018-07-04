//
//  AppConstants.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/23.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct AppConstants {
    static let appName: String = "Ladybug"
    static let groupID: String = "group.com.elaborapp.Ladybug"
    static var versionString: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static var buildString: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    static var aboutString: String = "\(appName) v\(versionString)(\(buildString))"
    static var copyrightString: String = "2018 Elaborapp Co., Ltd."

    static var feedbackEmail: String = "elaborapp+ladybug@gmail.com"

    static var appStoreURL: URL = URL(string: "https://itunes.apple.com/us/app/ladybug-handles-radar-links/id1402968134?l=zh&ls=1&mt=8&ct=Ladybug")!
    static var githubURL: URL = URL(string: "https://github.com/ethanhuang13/ladybug")!
    static var developerURL: URL = URL(string: "https://twitter.com/ethanhuang13")!
}
