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
                    DispatchQueue.main.async {
                        self.accessToken = tokenResponse.accessToken
                        self.isAuthenticated = true
                        
                        StorageManager.shared.saveAccessToken(self.accessToken)
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
                    DispatchQueue.main.async {
                        self.accessToken = token
                        self.isAuthenticated = true
                    }
                }
            }
            
        }
    }
}
