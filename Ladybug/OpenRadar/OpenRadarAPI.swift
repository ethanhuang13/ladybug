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
    case noResult
    case parseFailed
}

extension OpenRadarAPIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlInvalidString(_):
            return "URL invalid".localized()
        case .noData:
            return "No data".localized()
        case .noResult:
            return "No result".localized()
        case .parseFailed:
            return "Parse data failed".localized()
        }
    }
}

struct OpenRadarAPIResultObject<T: Codable>: Codable {
    let result: T
}

struct OpenRadarAPIResultArray<T: Codable>: Codable {
    let result: [T]
}

public struct OpenRadarAPI {
    private func performRequest(url: URL, completion: @escaping (_ result: Result<Data>) -> Void) {
        var request = URLRequest(url: url)
        request.addValue(AppConstants.userAgentString, forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let data = data else {
                completion(.error(OpenRadarAPIError.noData))
                return
            }

            completion(.value(data))
        }.resume()
    }

    public func fetchRadar(by radarNumber: RadarNumber, completion: @escaping (_ result: Result<Radar>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/radar?number=\(radarNumber.string)"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        performRequest(url: url) { (result) in
            switch result {
            case .value(let data):
                do {
                    let metadata = try JSONDecoder().decode(OpenRadarAPIResultObject<RadarMetadata>.self, from: data).result
                    guard let radar = Radar(metadata: metadata) else {
                        completion(.error(OpenRadarAPIError.noResult))
                        return
                    }
                    completion(.value(radar))
                } catch {
                    completion(.error(OpenRadarAPIError.noResult))
                    return
                }
            case .error(let error):
                completion(.error(error))
            }
        }
    }

    /// User is usually email

    public func fetchRadarsBy(user: String, completion: @escaping (_ result: Result<[Radar]>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/search?scope=user&q=\(user)"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        performRequest(url: url) { (result) in
            switch result {
            case .value(let data):
                do {
                    let array = try JSONDecoder().decode(OpenRadarAPIResultArray<RadarMetadata>.self, from: data).result
                    let radars = array.compactMap { Radar(metadata: $0) }
                    completion(.value(radars))
                } catch {
                    print(error.localizedDescription)
                    completion(.error(OpenRadarAPIError.parseFailed))
                    return
                }
            case .error(let error):
                completion(.error(error))
            }
        }
    }

    public func fetchRadarsBy(keywords: [String], completion: @escaping (_ result: Result<[Radar]>) -> Void) {
        let urlString = "https://openradar.appspot.com/api/search?q=\(keywords.joined(separator: ","))"
        guard let url = URL(string: urlString) else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlString)))
            return
        }

        performRequest(url: url) { (result) in
            switch result {
            case .value(let data):
                do {
                    let array = try JSONDecoder().decode(OpenRadarAPIResultArray<RadarMetadata>.self, from: data).result
                    let radars = array.compactMap { Radar(metadata: $0) }
                    completion(.value(radars))
                } catch {
                    print(error.localizedDescription)
                    completion(.error(OpenRadarAPIError.parseFailed))
                    return
                }
            case .error(let error):
                completion(.error(error))
            }
        }
    }
}
