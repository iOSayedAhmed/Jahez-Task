//
//  StorageKeys.swift
//  Jahez-Task
//
//  Created by iOSAYed on 19/08/2025.
//


struct StorageKeys {
    static let movies = "cached_movies"
    static let genres = "cached_genres"
    
    static func movieDetails(id: Int) -> String {
        return "movie_details_\(id)"
    }
    
    static func movieImage(url: String) -> String {
        let hash = abs(url.hashValue)
        return "movie_image_\(hash)"
    }
}