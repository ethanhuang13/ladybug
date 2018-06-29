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
    static private let metadataKey = "com.elaborapp.Ladybug.RadarCollection.metadata"

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
        let radarMetdata: [RadarID: RadarMetadata] = {
            if let metadataData = UserDefaults.standard.object(forKey: RadarCollection.metadataKey) as? Data {
                do {
                    let metadata = try PropertyListDecoder().decode([RadarID: RadarMetadata].self, from: metadataData)
                    print("Unarchived \(metadata.count) radar metadata")
                    return metadata
                } catch {
                    print(error.localizedDescription)
                }
            }
            return [:]
        }()

        if let data = UserDefaults.standard.object(forKey: RadarCollection.key) as? Data {
            do {
                let radars = try PropertyListDecoder().decode([RadarID: Radar].self, from: data)

                for radar in radars {
                    if let metadata = radarMetdata[radar.key] {
                        radar.value.metadata = metadata
                    }
                }

                self.radars = radars
                print("Unarchived \(radars.count) radars")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func archive() {
        do {
            let radarData = try PropertyListEncoder().encode(radars)
            UserDefaults.standard.set(radarData, forKey: RadarCollection.key)

            var radarMetdata: [RadarID: RadarMetadata] = [:]
            for radar in radars {
                if let metadata = radar.value.metadata {
                    radarMetdata[radar.key] = metadata
                }
            }

            let radarMetadataData = try PropertyListEncoder().encode(radarMetdata)
            UserDefaults.standard.set(radarMetadataData, forKey: RadarCollection.metadataKey)

            print("Archived \(radars.count) radars, \(radarMetdata.count) metadata")
        } catch {
            print(error.localizedDescription)
        }
    }

    /// This API has update policy

    public func upsert(radar: Radar) {
        if let existingRadar = radars[radar.id] {
            if existingRadar.bookmarkedDate == nil {
                existingRadar.bookmarkedDate = radar.bookmarkedDate
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

     /// Use when user toggle bookmark for a radar

    public func toggleBookmark(radarID: RadarID) throws {
        if let existingRadar = radars[radarID] {
            existingRadar.bookmarkedDate = existingRadar.bookmarkedDate != nil ? nil : Date()
            notifyDidUpdate()
        }
    }

    public func bookmark(radarIDs: [RadarID]) {
        for radarID in radarIDs {
            if let existingRadar = radars[radarID] {
                existingRadar.bookmarkedDate = existingRadar.bookmarkedDate != nil ? existingRadar.bookmarkedDate : Date()
            }
        }
        notifyDidUpdate()
    }

    public func history() -> [Radar] {
        let radars = self.radars.values.sorted { (lhs, rhs) -> Bool in
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
