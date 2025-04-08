//
//  ProfileView.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @ObservedObject var authManager = AuthManager.shared
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if authManager.isAuthenticated {
                    authenticatedView
                } else {
                    unauthenticatedView
                }
            }
            .navigationTitle(NSLocalizedString("个人资料", comment: ""))
        }
    }
    
    private var unauthenticatedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(NSLocalizedString("未登录", comment: ""))
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("登录后查看您的个人资料", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                authManager.loginWithGitHub()
            }) {
                Text(NSLocalizedString("登录", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Button(action: {
                authManager.loginWithBiometric()
            }) {
                Text(NSLocalizedString("面容登录", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var authenticatedView: some View {
        VStack {
            if let name = authManager.currentUser?.name {
                Text(name)
            } else {
                Text("No Name Available")
            }
            if let avatarUrl = authManager.currentUser?.avatarUrl {
                WebImage(url: URL(string: avatarUrl))
            } else {
                Image(systemName: "person.crop.circle.badge.questionmark")

            }
                                          
            Button(action: {
                authManager.logout()
            }) {
                Text(NSLocalizedString("登出", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    ProfileView()
}
