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
        if let string = RadarNumber.parse(url),
            let radarNumber = RadarNumber(string: string) {
            self = radarNumber
        } else {
            return nil
        }
    }

    static func parse(_ url: URL) -> String? {
        if url.scheme?.caseInsensitiveCompare("rdar") == .orderedSame,
            let host = url.host {
            if host == "problem" {
                return url.lastPathComponent
            } else {
                return host
            }
        } else if url.scheme?.caseInsensitiveHasPrefix("http") == true,
            url.host?.caseInsensitiveHasSuffix("openradar.appspot.com") == true {
            return url.lastPathComponent
        } else if url.scheme?.caseInsensitiveHasPrefix("http") == true,
            url.host?.caseInsensitiveHasSuffix("openradar.me") == true {
            return url.lastPathComponent
        } else if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme?.hasPrefix("http") == true,
            urlComponents.host == "bugreport.apple.com",
            urlComponents.path.hasPrefix("/web"),
            let string = urlComponents.queryItems?.filter({ $0.name == "problemID" }).first?.value {
            return string
        } else if let int = Int(url.lastPathComponent),
            String(int) == url.lastPathComponent {
            return url.lastPathComponent
        } else {
            return nil
        }
    }

    func url(by radarOption: RadarOption) -> URL {
        switch radarOption {
        case .appleRadar:
            return URL(string: "https://bugreport.apple.com/web/?problemID=\(rawValue)")!
        case .openRadar:
            return URL(string: "https://openradar.appspot.com/\(rawValue)")!
        case .brisk:
            return URL(string: "brisk-rdar://radar/\(rawValue)")!
        }
    }

    var rdarURLString: String {
        return "rdar://" + self.string
    }

    var string: String {
        return String(self.number)
    }
}
