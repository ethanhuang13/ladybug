//
//  RadarCollectionTests.swift
//  LadybugTests
//
//  Created by Ethanhuang on 2018/7/6.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import XCTest
@testable import Ladybug

class RadarCollectionTests: XCTestCase {
    let radarCollection: RadarCollection = RadarCollection()
    var radars: [RadarNumber: Radar] = [:]
    var fileURL: URL!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        testLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoad() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "test-radars", withExtension: "json") else {
            XCTFail("Missing file URL: test-radars.json")
            return
        }
        self.fileURL = fileURL

        do {
            let radars = try RadarCollection.load(from: fileURL)
            XCTAssert(radars.count == 22)
            self.radars = radars

            radars.forEach {
                XCTAssertNotNil($0.value.metadata)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUpsert() {
        radars.values.forEach {
            radarCollection.upsert(radar: $0)
        }

        radars.values.reversed().forEach {
            XCTAssertNotNil(radarCollection.radar($0.number))
        }
    }

    func testHistory() {
        radars.values.forEach {
            radarCollection.upsert(radar: $0)
        }
        XCTAssert(radarCollection.history().isEmpty)

        radars.values.reversed().forEach {
            try? radarCollection.updatedViewed(radarNumber: $0.number)
            radarCollection.upsert(radar: $0)
        }
        XCTAssert(radarCollection.history().count == 22)

        let radarNumbers = radars.values.map { $0.number }
        radarNumbers.forEach {
            radarCollection.removeFromHistory(radarNumber: $0)
        }
        XCTAssert(radarCollection.history().isEmpty)
    }

    func testBookmarks() {
        radars.values.forEach {
            radarCollection.upsert(radar: $0)
        }
        XCTAssert(radarCollection.bookmarks().count == 22)

        radars.values.reversed().forEach {
            try? radarCollection.toggleBookmark(radarNumber: $0.number)
            radarCollection.upsert(radar: $0)
        }
        XCTAssert(radarCollection.bookmarks().isEmpty)

        let radarNumbers = radars.values.map { $0.number }
        radarCollection.bookmark(radarNumbers: radarNumbers)
        XCTAssert(radarCollection.bookmarks().count == 22)
    }

    func testUnarchive() {
        radarCollection.unarchive()
    }

    func testArchive() {
        radarCollection.archive()
    }
}
