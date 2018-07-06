//
//  RadarURLParseError.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

enum RadarURLParseError: Error {
    case noValidRadarNumber
}

extension RadarURLParseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noValidRadarNumber:
            return "No valid radar number".localized()
        }
    }
}
