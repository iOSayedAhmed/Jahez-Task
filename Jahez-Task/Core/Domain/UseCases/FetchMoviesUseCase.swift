//
//  FetchMoviesUseCase.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class FetchMoviesUseCase: FetchMoviesUseCaseProtocol {
    private let repository: MoviesRepositoryProtocol
    
    init(repository: MoviesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(page: Int, forceRefresh: Bool = false) -> AnyPublisher<MoviesPage, DomainError> {
        if forceRefresh {
            return repository.fetchMovies(page: page)
        }
        
        return repository.fetchMovies(page: page)
            .catch { [weak self] error -> AnyPublisher<MoviesPage, DomainError> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // If network fails and it's the first page, try to return cached data
                if page == 1 {
                    return self.repository.fetchCachedMovies()
                        .map { movies in
                            MoviesPage(page: 1, movies: movies, totalPages: 1, totalResults: movies.count)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
