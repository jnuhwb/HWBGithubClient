//
//  ExploreViewModel.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import Foundation

class ExploreViewModel: ObservableObject {
    @Published var repositories: [Repository] = Repository.mockData
    @Published var isEditing: Bool = false
    @Published var searchText: String = ""
    
    
}
