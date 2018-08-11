//
//  UserDefaults+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import Echo

extension UserDefaults {
    internal static let browserKey: String = "com.elaborapp.Ladybug.browserKey"
    internal static let radarKey: String = "com.elaborapp.Ladybug.radarKey"
    internal static let sortKey: String = "com.elaborapp.Ladybug.sortKey"

    var browserOption: BrowserOption {
        get {
            return BrowserOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.browserKey)) ?? .native
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.browserKey)

            switch newValue {
            case .native:
                if self.radarOption != .openRadar {
                    self.radarOption = .openRadar
                }
            case .sfvcReader, .sfvc, .safari:
                if self.radarOption == .brisk {
                    self.radarOption = .openRadar
                }
            case .briskApp:
                if self.radarOption != .brisk {
                    self.radarOption = .brisk
                }
            }
        }
    }

    var radarOption: RadarOption {
        get {
            return RadarOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.radarKey)) ?? .openRadar
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.radarKey)

            switch newValue {
            case .openRadar:
                if self.browserOption == .briskApp {
                    self.browserOption = .native
                }
            case .appleRadar:
                if self.browserOption == .briskApp || self.browserOption == .native {
                    self.browserOption = .safari
                }
            case .brisk:
                if self.browserOption != .briskApp {
                    self.browserOption = .briskApp
                }
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
