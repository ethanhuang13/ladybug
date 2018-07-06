//
//  RadarTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/7/6.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class RadarTests: XCTestCase {
    let radar: Radar = Radar(number: RadarNumber(12345678), metadata: nil)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCellTitle() {
        XCTAssertFalse(radar.cellTitle.isEmpty)
    }

    func testCellSubtitle() {
        XCTAssertFalse(radar.cellSubtitle.isEmpty)
    }
}
