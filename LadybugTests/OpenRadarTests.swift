//
//  OpenRadarTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class OpenRadarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseURL() {
        let url = URL(string: "rdar://12345678")!
        let radarID = OpenRadar.parse(url)
        XCTAssertNotNil(radarID)
        XCTAssert(radarID?.id == "12345678")
    }

    func testBuildURL() {
        let radarID = RadarID(string: "12345678")
        let url = OpenRadar.buildURL(from: radarID)
        XCTAssertEqual(url.absoluteString, "https://openradar.appspot.com/12345678")
    }
}
