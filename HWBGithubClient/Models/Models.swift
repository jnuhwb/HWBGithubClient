//
//  Models.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let fullName: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case fullName = "full_name"
    }
}

extension Repository {
    static var mockData: [Repository] {
        return [
            Repository(id: 1, fullName: "swift/swift", description: "The Swift Programming Language"),
            Repository(id: 2, fullName: "apple/objc", description: "Objective-C programming language"),
            Repository(id: 3, fullName: "facebook/react", description: "A JavaScript library for building user interfaces")
        ]
    }
}

struct SearchResponse: Codable {
    let totalCount: Int
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
