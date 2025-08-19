//
//  MovieRepositoryProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol MoviesRepositoryProtocol {
    func fetchMovies(page: Int) -> AnyPublisher<MoviesPage, DomainError>
    func fetchCachedMovies() -> AnyPublisher<[Movie], DomainError>
    func cacheMovies(_ movies: [Movie]) -> AnyPublisher<Void, DomainError>
}
