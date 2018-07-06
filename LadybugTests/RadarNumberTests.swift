//
//  RadarNumberTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/7/6.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class RadarNumberTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitString() {
        let strings: [String] = [
            "https://bugreport.apple.com/web/?problemID=41075977",
            "RDAR://12345678",
            "rdar://12345678",
            "https://openradar.appspot.com/12345678",
            "http://openradar.me/12345678",
            "brisk-rdar://radar/12345678"
        ]

        strings.forEach {
            XCTAssertNotNil(RadarNumber(string: $0), $0)
        }
    }

    func testInitURLAppleRadar() {
        let url = URL(string: "https://bugreport.apple.com/web/?problemID=41075977")!
        let radarNumber = RadarNumber(url: url)
        XCTAssertNotNil(radarNumber)
        XCTAssert((radarNumber?.rawValue == 41075977) == true)
    }

    func testInitURLOpenRadar() {
        let urlStrings = ["rdar://12345678",
                          "https://openradar.appspot.com/12345678",
                          "http://openradar.me/12345678"]
        let urls = urlStrings.map { URL(string: $0)! }
        urls.forEach { (url) in
            let radarNumber = RadarNumber(url: url)
            XCTAssertNotNil(radarNumber)
            XCTAssert((radarNumber?.rawValue == 12345678) == true)
        }
    }

    func testInitURLBrisk() {
        let url = URL(string: "brisk-rdar://radar/12345678")!
        let radarNumber = RadarNumber(url: url)
        XCTAssertNotNil(radarNumber)
        XCTAssert((radarNumber?.rawValue == 12345678) == true)
    }

    func testString() {
        let radarNumber = RadarNumber(12345678)
        XCTAssert(radarNumber.string == "12345678")
    }

    func testBuildAppleRadarURL() {
        let radarNumber = RadarNumber(12345678)
        let url = radarNumber.url(by: .appleRadar)
        XCTAssertEqual(url.absoluteString, "https://bugreport.apple.com/web/?problemID=12345678")
    }

    func testBuildOpenRadarURL() {
        let radarNumber = RadarNumber(12345678)
        let url = radarNumber.url(by: .brisk)
        XCTAssertEqual(url.absoluteString, "brisk-rdar://radar/12345678")
    }

    func testBuildBriskURL() {
        let radarNumber = RadarNumber(12345678)
        let url = radarNumber.url(by: .openRadar)
        XCTAssertEqual(url.absoluteString, "https://openradar.appspot.com/12345678")
    }
}
