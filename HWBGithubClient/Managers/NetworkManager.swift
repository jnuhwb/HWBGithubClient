//
//  NetworkManager.swift
//  HWBGithubClient
//
//  Created by hwb on 2025/4/8.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的服务器响应"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .decodingError:
            return "数据解析错误"
        }
    }
}

class NetworkManager {
    static private let baseURL = "https://api.github.com"
    
    static func searchRepository(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let url = URL(string: baseURL + "/search/repositories") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc")
        ]
        
        guard let finalURL = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        print("请求url: \(finalURL)")
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("响应状态码: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 400 {
                completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SearchResponse.self, from: data)
                completion(.success(result))
            } catch {
                print("解码错误: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }
        
        task.resume()
    }
}
