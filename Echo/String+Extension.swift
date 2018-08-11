//
//  String+Extension.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

extension String {
    func caseInsensitiveHasPrefix(_ string: String) -> Bool {
        return self.lowercased().hasPrefix(string.lowercased())
    }

    func caseInsensitiveHasSuffix(_ string: String) -> Bool {
        return self.lowercased().hasSuffix(string.lowercased())
    }
}
