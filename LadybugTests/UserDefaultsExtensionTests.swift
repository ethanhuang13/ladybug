//
//  UserDefaultsExtensionTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/6/14.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class UserDefaultsExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSetRadarOption() {
        UserDefaults.standard.radarOption = .openRadar
        XCTAssert(UserDefaults.standard.radarOption == .openRadar)
        XCTAssert(UserDefaults.standard.browserOption != .briskApp)

        UserDefaults.standard.radarOption = .appleRadar
        XCTAssert(UserDefaults.standard.radarOption == .appleRadar)
        XCTAssert(UserDefaults.standard.browserOption != .briskApp)

        UserDefaults.standard.radarOption = .brisk
        XCTAssert(UserDefaults.standard.radarOption == .brisk)
        XCTAssert(UserDefaults.standard.browserOption == .briskApp)
    }
    
    func testSetBrowserOption() {
        UserDefaults.standard.browserOption = .sfvcReader
        XCTAssert(UserDefaults.standard.browserOption == .sfvcReader)
        XCTAssert(UserDefaults.standard.radarOption != .brisk)

        UserDefaults.standard.browserOption = .sfvc
        XCTAssert(UserDefaults.standard.browserOption == .sfvc)
        XCTAssert(UserDefaults.standard.radarOption != .brisk)

        UserDefaults.standard.browserOption = .safari
        XCTAssert(UserDefaults.standard.browserOption == .safari)
        XCTAssert(UserDefaults.standard.radarOption != .brisk)

        UserDefaults.standard.browserOption = .briskApp
        XCTAssert(UserDefaults.standard.browserOption == .briskApp)
        XCTAssert(UserDefaults.standard.radarOption == .brisk)
    }
}
