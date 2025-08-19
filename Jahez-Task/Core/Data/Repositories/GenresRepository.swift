//
//  GenresRepository.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class GenresRepository: GenresRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let localStorage: LocalStorageProtocol
    private let cacheFileName = "cached_genres"
    
    init(networkManager: NetworkManagerProtocol, localStorage: LocalStorageProtocol) {
        self.networkManager = networkManager
        self.localStorage = localStorage
    }
    
    func fetchGenres() -> AnyPublisher<[Genre], DomainError> {
        let request = MoviesAPIRequest.getGenres
        
        return networkManager.execute(request, responseType: GenresResponse.self)
            .map { response in
                response.genres.map(GenreMapper.toDomain)
            }
            .handleEvents(receiveOutput: { [weak self] genres in
                // Cache genres
                guard let self = self else { return }
                self.cacheGenres(genres)
                    .sink(receiveCompletion: { _ in }, receiveValue: { })
                    .store(in: &self.cancellables)
            })
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedGenres() -> AnyPublisher<[Genre], DomainError> {
        return localStorage.load([Genre].self, from: cacheFileName)
            .mapError { _ in DomainError.cacheError("Failed to load cached genres") }
            .eraseToAnyPublisher()
    }
    
    func cacheGenres(_ genres: [Genre]) -> AnyPublisher<Void, DomainError> {
        return localStorage.save(genres, to: cacheFileName)
            .mapError { _ in DomainError.cacheError("Failed to cache genres") }
            .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
