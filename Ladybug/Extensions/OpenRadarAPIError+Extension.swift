//
//  OpenRadarAPI+Extension.swift
//  Ladybug
//
//  Created by Robert Nash on 11/08/2018.
//  Copyright © 2018 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import Echo

extension OpenRadarAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .urlInvalidString(_):
            return "URL invalid".localized()
        case .requiresAPIKey:
            return "Requires API Key".localized()
        case .noData:
            return "No data".localized()
        case .noResult:
            return "No result".localized()
        case .parseFailed:
            return "Parse data failed".localized()
        }
    }
}
