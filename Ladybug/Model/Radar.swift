//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

class Radar: Codable {
    let id: RadarID
    var metadata: RadarMetadata?
    let firstViewedDate: Date
    var lastViewedDate: Date
    var favoritedDate: Date? = nil

    init(id: RadarID, metadata: RadarMetadata? = nil) {
        self.id = id
        self.metadata = metadata
        firstViewedDate = Date()
        lastViewedDate = Date()
    }

    var idString: String {
        return String(id.id)
    }
}
