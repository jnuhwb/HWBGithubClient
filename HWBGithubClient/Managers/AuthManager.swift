//
//  AuthManager.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import Foundation
import AuthenticationServices
import LocalAuthentication

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case invalidResponse
    case authenticationCancelled
    case presentationContextNotFound
    case failedFetchUser
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "认证失败"
        case .networkError:
            return "网络连接错误"
        case .invalidResponse:
            return "服务器响应无效"
        case .authenticationCancelled:
            return "认证已取消"
        case .presentationContextNotFound:
            return "无法显示登录界面"
        case .failedFetchUser:
            return "获取用户信息失败"
        }
        
    }
}

class AuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    private var webAuthSession: ASWebAuthenticationSession?
    
    private let clientId = "Iv23lityoWFa9jUErcNV"
    private let clientSecret = "cf5efed6ee616abe3f05e218f5ebfb5dd82bb472"
    private let redirectUri = "githubclient://callback"
    
    private var accessToken: String = ""
    @Published var currentUser: User?
    
    func loginWithGitHub() {
        let authorizationURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=repo,user&redirect_uri=\(redirectUri)")!
        
        let authSession = ASWebAuthenticationSession(url: authorizationURL, callbackURLScheme: "githubclient") { callbackURL, error in
            if let callbackURL = callbackURL {
                // 解析回调 URL，提取授权码
                if let code = self.extractCode(from: callbackURL) {
                    self.fetchAccessToken(code: code)
                }
            } else if let error = error {
                print("Authentication failed: \(error.localizedDescription)")
            }
        }
        
        authSession.presentationContextProvider = self
        authSession.start()
    }
    
    func extractCode(from url: URL) -> String? {
        // 从回调 URL 中提取授权码
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
    
    func fetchAccessToken(code: String) {
        let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUri
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                // 解析 JSON 响应，获取 access token
                if let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                    self.accessToken = tokenResponse.accessToken
                    StorageManager.shared.saveAccessToken(self.accessToken)

                    self.fetchUserProfile() { result in
                        switch result {
                        case .success(let user):
                            DispatchQueue.main.async {
                                self.currentUser = user
                                self.isAuthenticated = true
                            }
                        case .failure(let error):
                            print("获取仓库列表失败: \(error)")
                        }
                    }
                    
                }
            }
        }
        
        task.resume()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func loginWithBiometric() {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "使用生物识别登录"
        ) { success, error in
            if success {
                if let token = StorageManager.shared.getAccessToken() {
                    self.fetchUserProfile() { result in
                        switch result {
                        case .success(let user):
                            DispatchQueue.main.async {
                                self.accessToken = token
                                self.currentUser = user
                                self.isAuthenticated = true
                            }
                        case .failure(let error):
                            print("获取仓库列表失败: \(error)")
                        }
                    }
                }
            }
            
        }
    }
    
    func fetchUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = StorageManager.shared.getAccessToken() else { return }
        
        var request = URLRequest(url: URL(string: "https://api.github.com/user")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let str = String(data: data, encoding: .utf8)
                print(str)
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    completion(.success(user))
                } else {
                    completion(.failure(AuthError.failedFetchUser))
                }
            } else {
                completion(.failure(AuthError.failedFetchUser))
            }
        }
        task.resume()
    }
    
    func logout() {
        // 清除所有认证相关的数据
        StorageManager.shared.clearAccessToken()
        currentUser = nil
        isAuthenticated = false
    }
}
