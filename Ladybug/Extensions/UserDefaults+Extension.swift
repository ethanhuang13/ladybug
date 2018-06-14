//
//  UserDefaults+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {
    private var browserKey: String { return "com.elaborapp.Ladybug.browserKey" }
    private var radarKey: String { return "com.elaborapp.Ladybug.radarKey" }

    var browserOption: BrowserOption {
        get {
            return BrowserOption(rawValue: UserDefaults.standard.integer(forKey: browserKey)) ?? .sfvcReader
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: browserKey)

            if newValue == .briskApp && self.radarOption != .brisk {
                self.radarOption = .brisk
            } else if newValue != .briskApp && self.radarOption == .brisk {
                self.radarOption = .openRadar
            }
        }
    }

    var radarOption: RadarOption {
        get {
            return RadarOption(rawValue: UserDefaults.standard.integer(forKey: radarKey)) ?? .openRadar
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: radarKey)

            if newValue == .brisk && self.browserOption != .briskApp {
                self.browserOption = .briskApp
            } else if newValue != .brisk && self.browserOption == .briskApp {
                self.browserOption = .sfvcReader
            }
        }
    }
}
