//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public class Radar: Codable {
    public let number: RadarNumber
    public var metadata: RadarMetadata?
    let firstViewedDate: Date
    var lastViewedDate: Date? = nil
    public var bookmarkedDate: Date? = nil

    enum CodingKeys: String, CodingKey {
        case number = "number"
        case metadata = "open-radar"
        case firstViewedDate = "first-viewed"
        case lastViewedDate = "last-viewed"
        case bookmarkedDate = "bookmarked"
    }

    public init(number: RadarNumber, metadata: RadarMetadata? = nil) {
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
