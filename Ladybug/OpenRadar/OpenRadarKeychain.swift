//
//  OpenRadarKeychain.swift
//  Ladybug
//
//  Created by Ethanhuang on 2018/7/9.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import Security

struct OpenRadarKeychain {
    private static let accessibilityLevel: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    private static let service: String = "Ladybug"
    private static let username: String = "openradar"

    static func queryDictionary() -> [String: Any] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccessible as String: accessibilityLevel,
                                    kSecAttrAccount as String: username]
        return query
    }

    static func deleteAPIKey() -> Bool {
        let query = queryDictionary()
        return SecItemDelete(query as CFDictionary).hasNoError
    }

    static func set(apiKey: String) -> Bool {
        var query = queryDictionary()
        _ = deleteAPIKey()
        let data = apiKey.data(using: .utf8)
        query[kSecValueData as String] = data

        let status = SecItemAdd(query as CFDictionary, nil)
        return status.hasNoError
    }

    static func getAPIKey() -> String? {
        var query = queryDictionary()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status.hasNoError,
            let dict = result as? NSDictionary else {
                return nil
        }

        let password = (dict[kSecValueData as String] as? Data).flatMap { String(data: $0, encoding: .utf8) }
        return password
    }
}

private extension OSStatus {
    var hasNoError: Bool {
        return self == noErr
    }
}
