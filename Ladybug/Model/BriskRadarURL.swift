//
//  BriskRadar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct BriskRadarURL: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> RadarNumber? {
        let string = url.lastPathComponent
        if let int = Int(string),
            String(int) == string {
            return RadarNumber(int)
        } else {
            return nil
        }
    }

    static func buildURL(from radarNumber: RadarNumber) -> URL {
        return URL(string: "brisk-rdar://radar/\(radarNumber.rawValue)")!
    }
}
