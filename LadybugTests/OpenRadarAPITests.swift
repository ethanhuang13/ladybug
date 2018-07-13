//
//  OpenRadarAPITests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/7/13.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class OpenRadarAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        _ = OpenRadarKeychain.set(apiKey: "ladybug-unit-tests")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchRadarByNumber() {
        let radarNumber = RadarNumber(12345678)
        let expectation = XCTestExpectation(description: radarNumber.rdarURLString)
        OpenRadarAPI().fetchRadar(by: radarNumber) { (result) in
            switch result {
            case .value(_):
                expectation.fulfill()
            case .error(let error):
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchRadarsByUser() {
        let username = "blesserx@gmail.com"
        let expectation = XCTestExpectation(description: username)
        OpenRadarAPI().fetchRadarsBy(user: username) { (result) in
            switch result {
            case .value(let radars):
                XCTAssert(radars.count > 20)
                expectation.fulfill()
            case .error(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
