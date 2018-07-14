//
//  RadarCollection.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/25.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

protocol RadarCollectionDelegate {
    func radarCollectionDidUpdate()
}

class RadarCollection {
    static let shared = RadarCollection()

    var delegates: MulticastDelegate<RadarCollectionDelegate> = MulticastDelegate()

    static private let key = "com.elaborapp.Ladybug.RadarCollection"

    lazy var fileURL: URL = {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentDirectory.appendingPathComponent("ladybug-radars.json")
        return fileURL
    }()

    private var radars: [RadarNumber: Radar] = [:] {
        didSet {
            notifyDidUpdate()
        }
    }

    private func notifyDidUpdate() {
        delegates.invoke(invocation: { (delegate) in
            DispatchQueue.main.async {
                delegate.radarCollectionDidUpdate()
            }
        })
    }

    public func forceNotifyDelegates() {
        notifyDidUpdate()
    }

    public func unarchive() {
        do {
            self.radars = try RadarCollection.load(from: self.fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }

    public func archive() {
        do {
            let radars = self.radars.filter { $0.value.bookmarkedDate != nil || $0.value.lastViewedDate != nil }
            try RadarCollection.save(radars, to: self.fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }

    public static func load(from fileURL: URL) throws -> [RadarNumber: Radar] {
        do {
            let radars = try JSONDecoder().decode([RadarNumber: Radar].self, from: try Data(contentsOf: fileURL))
            print("Loaded \(radars.count) radars")
            return radars
        } catch {
            throw error
        }
    }

    public static func save(_ radars: [RadarNumber: Radar], to fileURL: URL) throws {
        do {
            try JSONEncoder().encode(radars).write(to: fileURL)
            print("Saved \(radars.count) radars")
        } catch {
            throw error
        }
    }

    public func merge(radars: [RadarNumber: Radar]) {
        let existingRadars = self.radars

        radars.values.forEach {
            if let existingRadar = existingRadars[$0.number] {
                if existingRadar.bookmarkedDate == nil {
                    existingRadar.bookmarkedDate = $0.bookmarkedDate
                }

                if existingRadar.lastViewedDate == nil {
                    existingRadar.lastViewedDate = $0.lastViewedDate
                }

                if let metadata = $0.metadata {
                    existingRadar.metadata = metadata
                }
            }
        }

        self.radars.merge(radars) { $1 }
    }

    public func replaceAll(radars: [RadarNumber: Radar]) {
        self.radars = radars
    }

    /// This API has update policy

    public func radar(_ radarNumber: RadarNumber) -> Radar? {
        return radars[radarNumber]
    }

    public func upsert(radar: Radar) -> Bool {
        var hasChange = false

        if let existingRadar = radars[radar.number] {
            if existingRadar.bookmarkedDate == nil {
                existingRadar.bookmarkedDate = radar.bookmarkedDate
                hasChange = true
            }

            if existingRadar.lastViewedDate == nil {
                existingRadar.lastViewedDate = radar.lastViewedDate
                hasChange = true
            }

            if let metadata = radar.metadata {
                existingRadar.metadata = metadata
                hasChange = true
            }
        } else {
            radars[radar.number] = radar
            hasChange = true
        }

        return hasChange
    }

    public func removeFromHistory(radarNumber: RadarNumber) {
        if let existingRadar = radars[radarNumber] {
            existingRadar.lastViewedDate = nil
            notifyDidUpdate()
        }
    }

    /// Use when user view a radar

    public func updatedViewed(radarNumber: RadarNumber) throws {
        if let existingRadar = radars[radarNumber] {
            existingRadar.lastViewedDate = Date()
            notifyDidUpdate()
        }
    }

     /// Use when user toggle bookmark for a radar

    public func toggleBookmark(radarNumber: RadarNumber) throws {
        if let existingRadar = radars[radarNumber] {
            existingRadar.bookmarkedDate = existingRadar.bookmarkedDate != nil ? nil : Date()
            notifyDidUpdate()
        }
    }

    public func bookmark(radarNumbers: [RadarNumber]) {
        for radarNumber in radarNumbers {
            if let existingRadar = radars[radarNumber] {
                existingRadar.bookmarkedDate = existingRadar.bookmarkedDate != nil ? existingRadar.bookmarkedDate : Date()
            }
        }
        notifyDidUpdate()
    }

    public func history(sortBy sortOption:SortOption = .addedDate) -> [Radar] {
        let historyRadars: [Radar] = radars.values.filter { $0.lastViewedDate != nil }
        switch sortOption {
        case .radarNumber:
            return historyRadars.sorted { (lhs, rhs) -> Bool in
                return lhs.number > rhs.number
            }
        case .addedDate:
            return historyRadars.sorted { (lhs, rhs) -> Bool in
                return lhs.firstViewedDate > rhs.firstViewedDate
            }
        }
    }

    public func bookmarks(sortBy sortOption:SortOption = .radarNumber) -> [Radar] {
        let bookmarkRadars: [Radar] = radars.values.filter { $0.bookmarkedDate != nil }
        switch sortOption {
        case .radarNumber:
            return bookmarkRadars.sorted { (lhs, rhs) -> Bool in
                return lhs.number > rhs.number
            }
        case .addedDate:
            return bookmarkRadars.sorted { (lhs, rhs) -> Bool in
                return lhs.bookmarkedDate! > rhs.bookmarkedDate!
            }
        }
    }
}
