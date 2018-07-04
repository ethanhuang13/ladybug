//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public class Radar: Codable {
    let number: RadarNumber
    var metadata: RadarMetadata?
    let firstViewedDate: Date
    var lastViewedDate: Date? = nil
    var bookmarkedDate: Date? = nil

    enum CodingKeys: String, CodingKey {
        case number = "number"
        case metadata = "open-radar"
        case firstViewedDate = "first-viewed"
        case lastViewedDate = "last-viewed"
        case bookmarkedDate = "bookmarked"
    }

    init(number: RadarNumber, metadata: RadarMetadata? = nil) {
        self.number = number
        self.metadata = metadata
        firstViewedDate = Date()
    }
}

extension Radar {
    convenience init?(metadata: RadarMetadata) {
        if let radarNumber = RadarNumber(string: metadata.number) {
            self.init(number: radarNumber, metadata: metadata)
        } else {
            return nil
        }
    }
}

extension Radar {
    var cellTitle: String {
        return number.string
    }

    var cellSubtitle: String {
        return metadata?.title ?? "(No record on Open Radar)".localized()
    }
}
