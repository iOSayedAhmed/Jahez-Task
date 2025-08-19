//
//  MoviesRepository.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class MoviesRepository: MoviesRepositoryProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    private let networkManager: NetworkManagerProtocol
    private let localStorage: LocalStorageProtocol
    private let cacheFileName = "cached_movies"
    
    init(networkManager: NetworkManagerProtocol, localStorage: LocalStorageProtocol) {
        self.networkManager = networkManager
        self.localStorage = localStorage
    }
    
    func fetchMovies(page: Int) -> AnyPublisher<MoviesPage, DomainError> {
        let request = MoviesAPIRequest.getMovies(page: page)
        
        return networkManager.execute(request, responseType: MoviesResponse.self)
            .map { response in
                let movies = response.results.map(MovieMapper.toDomain)
                return MoviesPage(
                    page: response.page,
                    movies: movies,
                    totalPages: response.totalPages,
                    totalResults: response.totalResults
                )
            }
            .handleEvents(receiveOutput: { [weak self] moviesPage in
                // Cache the first page
                if moviesPage.page == 1 {
                    guard let self = self else { return }
                    self.cacheMovies(moviesPage.movies)
                        .sink(receiveCompletion: { _ in }, receiveValue: { })
                        .store(in: &self.cancellables)
                }
            })
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedMovies() -> AnyPublisher<[Movie], DomainError> {
        return localStorage.load([Movie].self, from: cacheFileName)
            .mapError { _ in DomainError.cacheError("Failed to load cached movies") }
            .eraseToAnyPublisher()
    }
    
    func cacheMovies(_ movies: [Movie]) -> AnyPublisher<Void, DomainError> {
        return localStorage.save(movies, to: cacheFileName)
            .mapError { _ in DomainError.cacheError("Failed to cache movies") }
            .eraseToAnyPublisher()
    }
}
