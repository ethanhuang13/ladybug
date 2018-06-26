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

    private var radars: [RadarID: Radar] = [:] {
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
        if let data = UserDefaults.standard.object(forKey: RadarCollection.key) as? Data {
            do {
                let radars = try PropertyListDecoder().decode([RadarID: Radar].self, from: data)
                self.radars = radars
                print("Unarchived \(radars.count) radars")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func archive() {
        do {
            let data = try PropertyListEncoder().encode(radars)
            UserDefaults.standard.set(data, forKey: RadarCollection.key)
            print("Archived \(radars.count) radars")
        } catch {
            print(error.localizedDescription)
        }
    }

    /// This API has update policy

    public func upsert(radar: Radar) {
        if let existingRadar = radars[radar.id] {
            if existingRadar.favoritedDate == nil {
                existingRadar.favoritedDate = radar.favoritedDate
            }

            if radar.lastViewedDate > existingRadar.lastViewedDate {
                existingRadar.lastViewedDate = radar.lastViewedDate
            }

            if let metadata = radar.metadata {
                existingRadar.metadata = metadata
            }
        } else {
            radars[radar.id] = radar
        }
    }

    public func remove(radar: Radar) {
        radars.removeValue(forKey: radar.id)
    }

    /// Use when user view a radar

    public func updatedViewed(radarID: RadarID) throws {
        if let existingRadar = radars[radarID] {
            existingRadar.lastViewedDate = Date()
            notifyDidUpdate()
        }
    }

     /// Use when user toggle favorite for a radar

    public func toggleFavorite(radarID: RadarID) throws {
        if let existingRadar = radars[radarID] {
            existingRadar.favoritedDate = existingRadar.favoritedDate != nil ? nil : Date()
            notifyDidUpdate()
        }
    }

    public func history() -> [Radar] {
        let radars = self.radars.values.sorted { (lhs, rhs) -> Bool in
            return lhs.lastViewedDate > rhs.lastViewedDate
        }

        return radars
    }

    public func bookmarks() -> [Radar] {
        let radars = self.radars.values.filter { $0.favoritedDate != nil }.sorted { (lhs, rhs) -> Bool in
            return lhs.favoritedDate! > rhs.favoritedDate!
        }

        return radars
    }
}
