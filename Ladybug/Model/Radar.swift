//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public class Radar: Codable {
    let id: RadarID
    var metadata: RadarMetadata?
    let firstViewedDate: Date
    var lastViewedDate: Date? = nil
    var bookmarkedDate: Date? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case firstViewedDate
        case lastViewedDate
        case bookmarkedDate
    }

    init(id: RadarID, metadata: RadarMetadata? = nil) {
        self.id = id
        self.metadata = metadata
        firstViewedDate = Date()
    }

    var idString: String {
        return String(id.id)
    }
}

extension Radar {
    convenience init?(metadata: RadarMetadata) {
        if let radarId = RadarID(string: metadata.number) {
            self.init(id: radarId, metadata: metadata)
        } else {
            return nil
        }
    }
}

extension Radar {
    var cellTitle: String {
        return idString
    }

    var cellSubtitle: String {
        return metadata?.title ?? "(No record on Open Radar)".localized()
    }
}
