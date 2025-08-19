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
    private var cancellables = Set<AnyCancellable>()
    
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
                guard let self else {return}
                self.localStorage.save(genres, to: StorageKeys.genres)
                    .sink(receiveCompletion: { _ in }, receiveValue: { })
                    .store(in: &self.cancellables)
            })
            .catch { [weak self] error -> AnyPublisher<[Genre], DomainError> in
                // If network fails, try to return cached data
                guard let self = self else {
                    return Fail(error: DomainError.networkError(error)).eraseToAnyPublisher()
                }
                
                return self.fetchCachedGenres()
                    .eraseToAnyPublisher()
            }
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedGenres() -> AnyPublisher<[Genre], DomainError> {
        return localStorage.load([Genre].self, from: StorageKeys.genres)
            .catch { _ in
                // If no cached genres, return empty array
                Just([Genre]()).setFailureType(to: Error.self)
            }
            .mapError { _ in DomainError.cacheError("Failed to load cached genres") }
            .eraseToAnyPublisher()
    }
    
    func cacheGenres(_ genres: [Genre]) -> AnyPublisher<Void, DomainError> {
        return localStorage.save(genres, to: StorageKeys.genres)
            .mapError { _ in DomainError.cacheError("Failed to cache genres") }
            .eraseToAnyPublisher()
    }
}
