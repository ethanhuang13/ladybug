//
//  UserDefaults+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {
    internal static let browserKey: String = "com.elaborapp.Ladybug.browserKey"
    internal static let radarKey: String = "com.elaborapp.Ladybug.radarKey"
    internal static let sortKey: String = "com.elaborapp.Ladybug.sortKey"

    var browserOption: BrowserOption {
        get {
            return BrowserOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.browserKey)) ?? .sfvcReader
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.browserKey)

            if newValue == .briskApp && self.radarOption != .brisk {
                self.radarOption = .brisk
            } else if newValue != .briskApp && self.radarOption == .brisk {
                self.radarOption = .openRadar
            }
        }
    }

    var radarOption: RadarOption {
        get {
            return RadarOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.radarKey)) ?? .openRadar
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.radarKey)

            if newValue == .brisk && self.browserOption != .briskApp {
                self.browserOption = .briskApp
            } else if newValue != .brisk && self.browserOption == .briskApp {
                self.browserOption = .sfvcReader
            }
        }
    }

    var sortOption: SortOption {
        get {
            return SortOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.sortKey)) ?? .radarNumber
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.sortKey)
        }
    }
}
