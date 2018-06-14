//
//  AppleRadar.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

struct AppleRadar: RadarURLParser & RadarURLBuilder {
    static func parse(_ url: URL) -> RadarID? {
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.scheme?.hasPrefix("http") == true,
            urlComponents.host == "bugreport.apple.com",
            urlComponents.path.hasPrefix("/web"),
            let id = urlComponents.queryItems?.filter({ $0.name == "problemID" }).first?.value {
            return RadarID(string: id)
        } else {
            return nil
        }
    }

    static func buildURL(from radarID: RadarID) -> URL {
        return URL(string: "https://bugreport.apple.com/web/?problemID=\(radarID.id)")!
    }
}
