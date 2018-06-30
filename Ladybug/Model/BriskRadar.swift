//
//  BriskRadar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct BriskRadar: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> RadarID? {
        let string = url.lastPathComponent
        if let int = Int(string),
            String(int) == string {
            return RadarID(int)
        } else {
            return nil
        }
    }

    static func buildURL(from radarID: RadarID) -> URL {
        return URL(string: "brisk-rdar://radar/\(radarID.id)")!
    }
}
