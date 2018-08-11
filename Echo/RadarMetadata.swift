//
//  RadarMetadata.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

/// Open Radar format

public struct RadarMetadata: Codable {
    public let status: String
    public let resolved: String
    public let product: String
    public let description: String
    public let classification: String
    public let originated: String
    public let productVersion: String
    public let number: String
    public let user: String
    let id: Int
    public let title: String
    public let reproducible: String

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
