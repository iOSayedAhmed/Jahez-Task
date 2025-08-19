//
//  APIRequest.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation
// MARK: - Request Configuration
protocol APIRequest {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: Any]? { get }
    var body: Data? { get }
}

extension APIRequest {
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents(string: baseURL + path)
        
        // Add query parameters
        if let queryParams = queryParameters {
            components?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set headers
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
