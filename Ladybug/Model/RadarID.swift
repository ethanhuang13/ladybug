//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct RadarID: Codable {
    let id: String

    init(string: String) {
        self.id = string
    }
}

extension RadarID {
    init?(integer: Int) {
        let string = String(integer)
        if Int(string) == integer {
            self.id = string
        } else {
            return nil
        }
    }

    init?(url: URL) {
        if let radarID = OpenRadar.parse(url) {
            self = radarID
        } else if let radarID = AppleRadar.parse(url) {
            self = radarID
        } else if let radarID = BriskRadar.parse(url) {
            self = radarID
        } else {
            return nil
        }
    }

    func url(by radarOption: RadarOption) -> URL {
        switch radarOption {
        case .appleRadar:
            return AppleRadar.buildURL(from: self)
        case .openRadar:
            return OpenRadar.buildURL(from: self)
        case .brisk:
            return BriskRadar.buildURL(from: self)
        }
    }
}
