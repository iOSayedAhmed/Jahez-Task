//
//  Movie.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

// MARK: - Domain Entities
struct Movie: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let genreIds: [Int]
    
    var formattedReleaseYear: String {
        String(releaseDate.prefix(4))
    }
    
    var posterURL: String {
        guard let posterPath = posterPath else { return "" }
        return APIConfiguration.imageBaseURL + posterPath
    }
    
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
}
