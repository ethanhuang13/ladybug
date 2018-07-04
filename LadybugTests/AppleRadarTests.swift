//
//  AppleRadarTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/6/12.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class AppleRadarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseURL() {
        let url = URL(string: "https://bugreport.apple.com/web/?problemID=41075977")!
        let radarNumber = AppleRadarURL.parse(url)
        XCTAssertNotNil(radarNumber)
        XCTAssert((radarNumber?.rawValue == 41075977) == true)
    }
    
    func testBuildURL() {
        let radarID = RadarNumber(12345678)
        let url = AppleRadarURL.buildURL(from: radarID)
        XCTAssertEqual(url.absoluteString, "https://bugreport.apple.com/web/?problemID=12345678")
    }
}
