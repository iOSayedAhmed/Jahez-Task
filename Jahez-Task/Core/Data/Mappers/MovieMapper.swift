//
//  MovieMapper.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

struct MovieMapper: DataMapper {
    typealias NetworkModel = MovieResponse
    typealias DomainModel = Movie
    
    static func toDomain(_ networkModel: MovieResponse) -> Movie {
        return Movie(
            id: networkModel.id,
            title: networkModel.title,
            overview: networkModel.overview,
            posterPath: networkModel.posterPath,
            releaseDate: networkModel.releaseDate,
            voteAverage: networkModel.voteAverage,
            voteCount: networkModel.voteCount,
            genreIds: networkModel.genreIds
        )
    }
    
    static func toNetwork(_ domainModel: Movie) -> MovieResponse {
        return MovieResponse(
            id: domainModel.id,
            title: domainModel.title,
            overview: domainModel.overview,
            posterPath: domainModel.posterPath,
            releaseDate: domainModel.releaseDate,
            voteAverage: domainModel.voteAverage,
            voteCount: domainModel.voteCount,
            genreIds: domainModel.genreIds
        )
    }
}
