//
//  OpenRadar.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct OpenRadar: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> Radar? {
        if url.scheme == "rdar",
            let id = url.host,
            id == String(Int(id) ?? -1) {
            return Radar(id: id)
        } else if url.scheme?.hasPrefix("http") == true,
            url.host == "openradar.appspot.com",
            url.lastPathComponent == String(Int(url.lastPathComponent) ?? -1) {
            return Radar(id: url.lastPathComponent)
        } else if url.scheme?.hasPrefix("http") == true,
            url.host?.hasSuffix("openradar.me") == true,
            url.lastPathComponent == String(Int(url.lastPathComponent) ?? -1) {
            return Radar(id: url.lastPathComponent)
        } else {
            return nil
        }
    }

    static func buildURL(from radar: Radar) -> URL {
        return URL(string: "https://openradar.appspot.com/\(radar.id)")!
    }
}
