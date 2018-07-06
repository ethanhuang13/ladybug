//
//  RadarMetadata.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

/// Open Radar format

struct RadarMetadata: Codable {
    let status: String
    let resolved: String
    let product: String
    let description: String
    let classification: String
    let originated: String
    let productVersion: String
    let number: String
    let user: String
    let id: Int
    let title: String
    let reproducible: String

    enum CodingKeys: String, CodingKey {
        case status
        case resolved
        case product
        case description
        case classification
        case originated
        case productVersion = "product_version"
        case number
        case user
        case id
        case title
        case reproducible
    }
}
