//
//  Credential.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/11.
//

import Foundation
import SwiftKeychainWrapper

class BiometricsManager {
    static var shared: BiometricsManager = BiometricsManager()
    private init() {}
}

struct Credentials: Codable {
    var email: String?
    var password: String?
    func encode() -> String {
        let encoder = JSONEncoder()
        if let credentials = try? encoder.encode(self) {
            return String(data: credentials, encoding: .utf8) ?? ""
        }
        return ""
    }
    static func decode(credentials: String) -> Credentials? {
        let decoder = JSONDecoder()
        guard let jsonData = credentials.data(using: .utf8) else { return nil }
        guard let credentials = try? decoder.decode(Credentials.self, from: jsonData) else { return nil }
        return credentials
    }
}
struct KeyChainStorage {
    static var key = "credentials"
    static func getCredentials() -> Credentials? {
        if let credentials = KeychainWrapper.standard.string(forKey: key) {
            return Credentials.decode(credentials: credentials)
        }
        return nil
    }
    static func saveCredentials(credentials: Credentials) {
        KeychainWrapper.standard.set(credentials.encode(), forKey: key)
    }
}
