//
//  OpenRadarAPI.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

enum OpenRadarAPIError: Error {
    case urlInvalidString(String)
    case noData
    case parseFailed
}

struct OpenRadarAPIResultObject<T: Codable>: Codable {
    let result: T
}

struct OpenRadarAPIResultArray<T: Codable>: Codable {
    let result: [T]
}

public struct OpenRadarAPI {
    public func fetchRadar(by radarID: RadarID, completion: @escaping (_ result: Result<Radar>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/radar?number=\(radarID.idString)"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let data = data else {
                completion(.error(OpenRadarAPIError.noData))
                return
            }

            do {
                let metadata = try JSONDecoder().decode(OpenRadarAPIResultObject<RadarMetadata>.self, from: data).result
                guard let radar = Radar(metadata: metadata) else {
                    completion(.error(OpenRadarAPIError.parseFailed))
                    return
                }
                completion(.value(radar))
            } catch {
                print(error.localizedDescription)
                completion(.error(OpenRadarAPIError.parseFailed))
                return
            }
        }.resume()
    }

    /// User is usually email

    public func fetchRadarsBy(user: String, completion: @escaping (_ result: Result<[Radar]>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/search?scope=user&q=\(user)"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let data = data else {
                completion(.error(OpenRadarAPIError.noData))
                return
            }

            do {
                let array = try JSONDecoder().decode(OpenRadarAPIResultArray<RadarMetadata>.self, from: data).result
                let radars = array.compactMap { Radar(metadata: $0) }
                completion(.value(radars))
            } catch {
                print(error.localizedDescription)
                completion(.error(OpenRadarAPIError.parseFailed))
                return
            }
            }.resume()
    }

    public func fetchRadarsBy(keywords: [String], completion: @escaping (_ result: Result<[Radar]>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/search?q=\(keywords.joined(separator: ","))"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let data = data else {
                completion(.error(OpenRadarAPIError.noData))
                return
            }

            do {
                let array = try JSONDecoder().decode(OpenRadarAPIResultArray<RadarMetadata>.self, from: data).result
                let radars = array.compactMap { Radar(metadata: $0) }
                completion(.value(radars))
            } catch {
                print(error.localizedDescription)
                completion(.error(OpenRadarAPIError.parseFailed))
                return
            }
            }.resume()
    }
}
