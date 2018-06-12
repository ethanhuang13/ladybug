//
//  Radar.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct Radar {
    let id: String

    init?(url: URL) {
        if let radar = OpenRadar.parse(url) {
            self = radar
        } else if let radar = AppleRadar.parse(url) {
            self = radar
        } else {
            return nil
        }
    }

    init(id: String) {
        self.id = id
    }

    func url(by radarOption: RadarOption) -> URL {
        switch radarOption {
        case .appleRadar:
            return AppleRadar.buildURL(from: self)
        case .openRadar:
            return OpenRadar.buildURL(from: self)
        }
    }
}
