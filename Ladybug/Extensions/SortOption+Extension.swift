//
//  SortOption+Extension.swift
//  Ladybug
//
//  Created by Robert Nash on 11/08/2018.
//  Copyright © 2018 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import Echo

extension SortOption {
    var title: String {
        switch self {
        case .radarNumber:
            return "Radar Number"
        case .addedDate:
            return "Added Date".localized()
        }
    }
}
