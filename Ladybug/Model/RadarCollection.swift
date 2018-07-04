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

    public func unarchive() {
        if let data = UserDefaults(suiteName: AppConstants.groupID)?.object(forKey: RadarCollection.key) as? Data {
            do {
                let radars = try JSONDecoder().decode([RadarNumber: Radar].self, from: data)
                self.radars = radars
                print("Unarchived \(radars.count) radars")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func archive() {
        do {
            let radarData = try JSONEncoder().encode(radars)
            UserDefaults(suiteName: AppConstants.groupID)?.set(radarData, forKey: RadarCollection.key)

            print("Archived \(radars.count) radars")
        } catch {
            print(error.localizedDescription)
        }
    }

    /// This API has update policy

    public func radar(_ radarNumber: RadarNumber) -> Radar? {
        return radars[radarNumber]
    }

    public func upsert(radar: Radar) {
        if let existingRadar = radars[radar.number] {
            if existingRadar.bookmarkedDate == nil {
                existingRadar.bookmarkedDate = radar.bookmarkedDate
            }

            if existingRadar.lastViewedDate == nil {
                existingRadar.lastViewedDate = radar.lastViewedDate
            }

            if let metadata = radar.metadata {
                existingRadar.metadata = metadata
            }
        } else {
            radars[radar.number] = radar
        }
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

    public func history() -> [Radar] {
        let radars = self.radars.values.filter { $0.lastViewedDate != nil }.sorted { (lhs, rhs) -> Bool in
            return lhs.firstViewedDate > rhs.firstViewedDate
        }

        return radars
    }

    public func bookmarks() -> [Radar] {
        let radars = self.radars.values.filter { $0.bookmarkedDate != nil }.sorted { (lhs, rhs) -> Bool in
            return lhs.bookmarkedDate! > rhs.bookmarkedDate!
        }

        return radars
    }
}
