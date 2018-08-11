//
//  URLOpenError.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

enum RadarURLOpenerError: Error {
    case cannotOpenIn(BrowserOption)
    case appOpenURLError
    case delegateIsNil
    case cancelled
}
