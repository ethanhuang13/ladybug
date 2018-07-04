//
//  Radar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public struct RadarNumber: Codable, RawRepresentable {
    public typealias RawValue = Int

    private let number: Int

    public init(rawValue: RawValue) {
        number = rawValue
    }

    public init(_ number: Int) {
        self.number = number
    }

    public var rawValue: Int {
        return number
    }
}

extension RadarNumber: Hashable {
    public var hashValue: Int { return rawValue }
}

public func == (lhs: RadarNumber, rhs: RadarNumber) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension RadarNumber {
    init?(string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if let int = Int(trimmedString),
            String(int) == trimmedString {
            self.number = int
        } else if let url = URL(string:trimmedString),
            let radarNumber = RadarNumber(url: url) {
            self = radarNumber
        } else {
            return nil
        }
    }

    init?(url: URL) {
        if let radarNumber = OpenRadarURL.parse(url) {
            self = radarNumber
        } else if let radarNumber = AppleRadarURL.parse(url) {
            self = radarNumber
        } else if let radarNumber = BriskRadarURL.parse(url) {
            self = radarNumber
        } else {
            return nil
        }
    }

    func url(by radarOption: RadarOption) -> URL {
        switch radarOption {
        case .appleRadar:
            return AppleRadarURL.buildURL(from: self)
        case .openRadar:
            return OpenRadarURL.buildURL(from: self)
        case .brisk:
            return BriskRadarURL.buildURL(from: self)
        }
    }
}

extension RadarNumber {
    var string: String {
        return String(self.number)
    }
}
