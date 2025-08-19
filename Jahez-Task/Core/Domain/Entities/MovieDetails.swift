//
//  MovieDetails.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

struct MovieDetails: Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let budget: Int
    let revenue: Int
    let status: String
    let homepage: String?
    let genres: [Genre]
    let spokenLanguages: [SpokenLanguage]
    
    var posterURL: String {
        guard let posterPath = posterPath else { return "" }
        return APIConfiguration.imageBaseURL + posterPath
    }
    
    var formattedReleaseYear: String {
        String(releaseDate.prefix(4))
    }
    
    var titleWithYear: String {
        "\(title) (\(formattedReleaseYear))"
    }
    
    var genreNames: String {
        genres.map { $0.name }.joined(separator: ", ")
    }
    
    var languageNames: String {
        spokenLanguages.map { $0.name }.joined(separator: ", ")
    }
    
    var formattedRuntime: String {
        guard let runtime = runtime else { return "Unknown" }
        return "\(runtime) minutes"
    }
    
    var formattedBudget: String {
        budget > 0 ? "$\(budget.formatted())" : "Not disclosed"
    }
    
    var formattedRevenue: String {
        revenue > 0 ? "$\(revenue.formatted())" : "Not disclosed"
    }
}

struct SpokenLanguage: Identifiable, Equatable {
    let id = UUID()
    let englishName: String
    let name: String
}
