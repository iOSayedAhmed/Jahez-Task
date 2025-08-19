//
//  MovieGenreService.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation

final class MovieGenreService: MovieGenreServiceProtocol {
    func getGenreNames(for genreIds: [Int], from genres: [Genre]) -> [String] {
        let genreDict = Dictionary(uniqueKeysWithValues: genres.map { ($0.id, $0.name) })
        return genreIds.compactMap { genreDict[$0] }
    }
    
    func getGenre(by id: Int, from genres: [Genre]) -> Genre? {
        return genres.first { $0.id == id }
    }
}
