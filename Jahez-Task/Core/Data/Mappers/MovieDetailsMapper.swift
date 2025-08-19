//
//  MovieDetailsMapper.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

struct MovieDetailsMapper: DataMapper {
    typealias NetworkModel = MovieDetailsResponse
    typealias DomainModel = MovieDetails
    
    static func toDomain(_ networkModel: MovieDetailsResponse) -> MovieDetails {
        return MovieDetails(
            id: networkModel.id,
            title: networkModel.title,
            overview: networkModel.overview,
            posterPath: networkModel.posterPath,
            releaseDate: networkModel.releaseDate,
            voteAverage: networkModel.voteAverage,
            voteCount: networkModel.voteCount,
            runtime: networkModel.runtime,
            budget: networkModel.budget,
            revenue: networkModel.revenue,
            status: networkModel.status,
            homepage: networkModel.homepage,
            genres: networkModel.genres.map(GenreMapper.toDomain),
            spokenLanguages: networkModel.spokenLanguages.map { response in
                SpokenLanguage(englishName: response.englishName, name: response.name)
            }
        )
    }
    
    static func toNetwork(_ domainModel: MovieDetails) -> MovieDetailsResponse {
        return MovieDetailsResponse(
            id: domainModel.id,
            title: domainModel.title,
            overview: domainModel.overview,
            posterPath: domainModel.posterPath,
            releaseDate: domainModel.releaseDate,
            voteAverage: domainModel.voteAverage,
            voteCount: domainModel.voteCount,
            runtime: domainModel.runtime,
            budget: domainModel.budget,
            revenue: domainModel.revenue,
            status: domainModel.status,
            homepage: domainModel.homepage,
            genres: domainModel.genres.map(GenreMapper.toNetwork),
            spokenLanguages: domainModel.spokenLanguages.map { domain in
                SpokenLanguageResponse(englishName: domain.englishName, name: domain.name)
            }
        )
    }
}
