//
//  BrowserOption+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension BrowserOption {
    var title: String {
        switch self {
        case .sfvcReader, .sfvc:
            return "In-app Browser".localized()
        case .safari:
            return "Safari".localized()
        case .briskApp:
            return "Brisk".localized()
        case .ask:
            return ""
        }
    }
}
