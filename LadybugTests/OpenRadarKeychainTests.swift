//
//  OpenRadarKeychainTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/7/9.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class OpenRadarKeychainTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        _ = OpenRadarKeychain.deleteAPIKey()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        _ = OpenRadarKeychain.deleteAPIKey()
    }

    func testDeleteAPIKey() {
        let setSuccess = OpenRadarKeychain.set(apiKey: "reqfrel-weqfekqe-qwef")
        XCTAssert(setSuccess)
        let deleteSuccess = OpenRadarKeychain.deleteAPIKey()
        XCTAssert(deleteSuccess)

        XCTAssertNil(OpenRadarKeychain.getAPIKey())
    }

    func testSetAPIKey() {
        let apiKey = "ewoifh8-123kewf-g9w12m"
        let setSuccess = OpenRadarKeychain.set(apiKey: apiKey)
        XCTAssert(setSuccess)

        let getAPIKey = OpenRadarKeychain.getAPIKey()
        XCTAssertNotNil(getAPIKey)
        XCTAssertEqual(getAPIKey, apiKey)
    }

    func testReplaceAPIKey() {
        let firstAPIKey = "wefhfio1-23rldvnkx"
        let firstSecSuccess = OpenRadarKeychain.set(apiKey: firstAPIKey)
        XCTAssert(firstSecSuccess)

        let secondAPIKey = "re0yv8rehf2-23eewfewf"
        let secondSecSuccess = OpenRadarKeychain.set(apiKey: secondAPIKey)
        XCTAssert(secondSecSuccess)

        XCTAssertEqual(secondAPIKey, OpenRadarKeychain.getAPIKey())
    }
}
