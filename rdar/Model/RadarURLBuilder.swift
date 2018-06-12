//
//  RadarURLBuilder.swift
//  rdar
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

protocol RadarURLBuilder {
    static func buildURL(from radar: Radar) -> URL
}
