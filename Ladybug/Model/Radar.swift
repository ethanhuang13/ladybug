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

    init(id: RadarID, metadata: RadarMetadata? = nil) {
        self.id = id
        self.metadata = metadata
    }
}
