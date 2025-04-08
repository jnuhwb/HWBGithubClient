//
//  MainTabView.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(NSLocalizedString("home", comment: ""))
                }
                .tag(0)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text(NSLocalizedString("profile", comment: ""))
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}
