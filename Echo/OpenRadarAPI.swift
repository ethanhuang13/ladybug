//
//  OpenRadarAPI.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/6/26.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public enum OpenRadarAPIError: Error {
    case urlInvalidString(String)
    case requiresAPIKey
    case noData
    case noResult
    case parseFailed
}

extension OpenRadarAPIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .urlInvalidString(_):
            return "URL invalid"
        case .requiresAPIKey:
            return "Requires API Key"
        case .noData:
            return "No data"
        case .noResult:
            return "No result"
        case .parseFailed:
            return "Parse data failed"
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
    public init() {}
    private func performRequest(url: URL, completion: @escaping (_ result: Result<Data>) -> Void) {
        guard let apiKey = OpenRadarKeychain.getAPIKey() else {
            completion(.error(OpenRadarAPIError.requiresAPIKey))
            return
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
//        request.addValue(userAgentString, forHTTPHeaderField: "User-Agent")

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
        let countPerPage = 100

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "openradar.appspot.com"
        urlComponents.path = "/api/search"
        urlComponents.queryItems = [URLQueryItem(name: "scope", value: "user"),
                                    URLQueryItem(name: "q", value: user),
                                    URLQueryItem(name: "count", value: String(countPerPage))]

        guard urlComponents.url != nil else {
            completion(.error(OpenRadarAPIError.urlInvalidString(urlComponents.debugDescription)))
            return
        }

        var allRadars: [Radar] = []

        func fetchNextPage(_ page: Int) {
            var pagedURLComponents = urlComponents
            pagedURLComponents.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
            let pagedURL = pagedURLComponents.url!

            self.performRequest(url: pagedURL) { (result) in
                switch result {
                case .value(let data):
                    do {
                        let array = try JSONDecoder().decode(OpenRadarAPIResultArray<RadarMetadata>.self, from: data).result
                        let radars = array.compactMap { Radar(metadata: $0) }
                        allRadars.append(contentsOf: radars)

                        if radars.count >= countPerPage {
                            fetchNextPage(page + 1)
                        } else {
                            completion(.value(allRadars))
                        }
                    } catch {
                        completion(.error(error))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }

        fetchNextPage(1)
    }

    func fetchRadarsBy(keywords: [String], completion: @escaping (_ result: Result<[Radar]>) -> Void) {
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
