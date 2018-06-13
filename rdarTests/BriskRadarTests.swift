//
//  BriskRadarTests.swift
//  rdarTests
//
//  Created by Ethanhuang on 2018/6/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import rdar

class BriskRadarTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseURL() {
        let url = URL(string: "brisk-rdar://radar/12345678")!
        let radarID = BriskRadar.parse(url)
        XCTAssertNotNil(radarID)
        XCTAssert(radarID?.id == "12345678")
    }

    func testBuildURL() {
        let radarID = RadarID(string: "12345678")
        let url = BriskRadar.buildURL(from: radarID)
        XCTAssertEqual(url.absoluteString, "brisk-rdar://radar/12345678")
    }
}
