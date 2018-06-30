//
//  RadarURLParser.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

protocol RadarURLParser {
    static func parse(_ url: URL) -> RadarID?
}

enum RadarURLParserError: Error {
    case noValidRadarNumber
}

extension RadarURLParserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noValidRadarNumber:
            return "No valid radar number".localized()
        }
    }
}
