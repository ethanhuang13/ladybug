//
//  BriskRadarTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class BriskRadarTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseURL() {
        let url = URL(string: "brisk-rdar://radar/12345678")!
        let radarNumber = BriskRadarURL.parse(url)
        XCTAssertNotNil(radarNumber)
        XCTAssert((radarNumber?.rawValue == 12345678) == true)
    }

    func testBuildURL() {
        let radarID = RadarNumber(12345678)
        let url = BriskRadarURL.buildURL(from: radarID)
        XCTAssertEqual(url.absoluteString, "brisk-rdar://radar/12345678")
    }
}
