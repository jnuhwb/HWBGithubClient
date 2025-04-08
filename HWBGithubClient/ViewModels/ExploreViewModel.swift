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
    @Published var isLoading = false
    
    func fetchRepositories(keyword: String?) {
        isLoading = true
        
        var query = "stars:>1000"
        if let kw = keyword {
            query += "+name:\(kw)"
        }
        NetworkManager.searchRepository(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    print("获取到 \(response.items.count) 个仓库")
                    self?.repositories = response.items
                case .failure(let error):
                    print("获取仓库列表失败: \(error)")
//                    self?.error = error
                }
            }
        }
    }
}
