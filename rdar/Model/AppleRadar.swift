//
//  AppleRadar.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct AppleRadar: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> Radar? {
        if url.scheme?.hasPrefix("http") == true,
            url.host == "bugreport.apple.com",
            url.path.hasPrefix("/web"),
            url.lastPathComponent.hasPrefix("problemID=") {
            let id = url.lastPathComponent.replacingOccurrences(of: "problemID=", with: "")
            return Radar(id: id)
        } else {
            return nil
        }
    }

    static func buildURL(from radar: Radar) -> URL {
        return URL(string: "https://bugreport.apple.com/web/problemID=\(radar.id)")!
    }
}
