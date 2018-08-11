//
//  RadarURLParseError+Extension.swift
//  Ladybug
//
//  Created by Robert Nash on 11/08/2018.
//  Copyright © 2018 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import Echo

extension RadarURLParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noValidRadarNumber:
            return "No valid radar number".localized()
        }
    }
}
