//
//  Constants.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation


enum Config {
    static var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("Api Key not found")
        }
        return key
    }
}

// MARK: - API Configuration
struct APIConfiguration {
    static let baseURL = "https://api.themoviedb.org/3/"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    static var apiKey: String {
        return Config.apiKey
    }
}



