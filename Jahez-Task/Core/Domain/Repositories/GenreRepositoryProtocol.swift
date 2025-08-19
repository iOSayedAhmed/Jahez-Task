//
//  GenreRepositoryProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol GenresRepositoryProtocol {
    func fetchGenres() -> AnyPublisher<[Genre], DomainError>
    func fetchCachedGenres() -> AnyPublisher<[Genre], DomainError>
    func cacheGenres(_ genres: [Genre]) -> AnyPublisher<Void, DomainError>
}
