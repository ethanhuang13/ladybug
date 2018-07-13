//
//  SortOption.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/7/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

enum SortOption: Int {
    case radarNumber
    case addedDate
}

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
