//
//  OpenRadar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct OpenRadarURL: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> RadarNumber? {
        if url.scheme == "rdar",
            let id = url.host {
            return RadarNumber(string: id)
        } else if url.scheme?.caseInsensitiveHasPrefix("http") == true,
            url.host?.caseInsensitiveHasSuffix("openradar.appspot.com") == true {
            return RadarNumber(string: url.lastPathComponent)
        } else if url.scheme?.caseInsensitiveHasPrefix("http") == true,
            url.host?.caseInsensitiveHasSuffix("openradar.me") == true {
            return RadarNumber(string: url.lastPathComponent)
        } else {
            return nil
        }
    }

    static func buildURL(from radarNumber: RadarNumber) -> URL {
        return URL(string: "https://openradar.appspot.com/\(radarNumber.rawValue)")!
    }
}
