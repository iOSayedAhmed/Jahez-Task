//
//  MovieGenreServiceProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation

protocol MovieGenreServiceProtocol {
    func getGenreNames(for genreIds: [Int], from genres: [Genre]) -> [String]
    func getGenre(by id: Int, from genres: [Genre]) -> Genre?
}
