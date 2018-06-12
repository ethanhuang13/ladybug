//
//  UserDefaults+Extension.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {
    private var browserKey: String { return "com.elaborapp.rdar.browserKey" }
    private var radarKey: String { return "com.elaborapp.rdar.radarKey" }

    var browserOption: BrowserOption {
        get {
            return BrowserOption(rawValue: UserDefaults.standard.integer(forKey: browserKey)) ?? .safari
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: browserKey)
        }
    }

    var radarOption: RadarOption {
        get {
            return RadarOption(rawValue: UserDefaults.standard.integer(forKey: radarKey)) ?? .openRadar
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: radarKey)
        }
    }
}
