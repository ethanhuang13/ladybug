//
//  RadarOption+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/14.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension RadarOption {
    var title: String {
        switch self {
        case .openRadar:
            return "Open Radar".localized()
        case .appleRadar:
            return "Apple Radar (Bug Reporter)".localized()
        case .brisk:
            return "Brisk"
        }
    }
}
