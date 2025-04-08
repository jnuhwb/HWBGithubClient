//
//  ExploreView.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        VStack {
            SearchView(isEditing: viewModel.isEditing, searchText: viewModel.searchText)
            List(viewModel.repositories, id: \.id) { repo in
                RepositoryRow(repository: repo)
            }
        }
        .onAppear() {
            viewModel.fetchRepositories(keyword: "")
        }
    }
}

struct RepositoryRow: View {
    let repository: Repository
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "book")
                Text(repository.fullName)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(repository.description)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SearchView: View {
    @State var isEditing: Bool
    @State var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search...", text: $searchText, onEditingChanged: { isEditing in
                self.isEditing = isEditing
            })
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color.gray.opacity(0.1))
            .overlay(
                HStack {
                    if isEditing {
                        Spacer()
                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
            )
        }
        .padding()
    }
}

#Preview {
    ExploreView()
}
