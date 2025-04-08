//
//  AuthManager.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = true
}
