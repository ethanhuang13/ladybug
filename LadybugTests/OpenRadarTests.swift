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
    
    func testParseURLs() {
        let urlStrings = ["rdar://12345678",
                          "https://openradar.appspot.com/12345678",
                          "http://openradar.me/12345678"]
        let urls = urlStrings.map { URL(string: $0)! }
        urls.forEach { (url) in
            let radarNumber = OpenRadarURL.parse(url)
            XCTAssertNotNil(radarNumber)
            XCTAssert((radarNumber?.rawValue == 12345678) == true)
        }
    }

    func testBuildURL() {
        let radarID = RadarNumber(12345678)
        let url = OpenRadarURL.buildURL(from: radarID)
        XCTAssertEqual(url.absoluteString, "https://openradar.appspot.com/12345678")
    }
}
