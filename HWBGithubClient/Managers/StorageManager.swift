//
//  StorageManager.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/9.
//

import Foundation
import KeychainAccess

class StorageManager {
    static let shared = StorageManager()
    private let keychain = Keychain(service: "com.githubclient")
    private let accessTokenKey = "github_access_token"
    
    private init() {}
    
    func saveAccessToken(_ token: String) {
        try? keychain.set(token, key: accessTokenKey)
    }
    
    func getAccessToken() -> String? {
        try? keychain.get(accessTokenKey)
    }
    
    func clearAccessToken() {
        try? keychain.remove(accessTokenKey)
    }
}
