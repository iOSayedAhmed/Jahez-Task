//
//  MoviesRepository.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation
import Combine
import UIKit

final class MoviesRepository: MoviesRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let localStorage: LocalStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
                // Cache movies and their images for offline access
                if moviesPage.page == 1 {
                    self?.cacheMoviesWithImages(moviesPage.movies)
                }
            })
            .catch { [weak self] error -> AnyPublisher<MoviesPage, DomainError> in
                // If network fails, try to return cached data
                guard let self = self, page == 1 else {
                    return Fail(error: DomainError.networkError(error)).eraseToAnyPublisher()
                }
                
                return self.fetchCachedMovies()
                    .map { movies in
                        MoviesPage(page: 1, movies: movies, totalPages: 1, totalResults: movies.count)
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedMovies() -> AnyPublisher<[Movie], DomainError> {
        return localStorage.load([Movie].self, from: StorageKeys.movies)
            .catch { _ in
                // If no cached movies, return empty array
                Just([Movie]()).setFailureType(to: Error.self)
            }
            .mapError { _ in DomainError.cacheError("Failed to load cached movies") }
            .eraseToAnyPublisher()
    }
    
    func cacheMovies(_ movies: [Movie]) -> AnyPublisher<Void, DomainError> {
        return localStorage.save(movies, to: StorageKeys.movies)
            .mapError { _ in DomainError.cacheError("Failed to cache movies") }
            .eraseToAnyPublisher()
    }
    
    private func cacheMoviesWithImages(_ movies: [Movie]) {
        // Cache movies data
        localStorage.save(movies, to: StorageKeys.movies)
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &cancellables)
        
        // Cache movie poster images
        for movie in movies {
            cacheMovieImage(movie)
        }
    }
    
    private func cacheMovieImage(_ movie: Movie) {
        guard !movie.posterURL.isEmpty, let url = URL(string: movie.posterURL) else { return }
        
        let filename = StorageKeys.movieImage(url: movie.posterURL)
        
        // Skip if image already cached
        if localStorage.imageExists(fileName: filename) {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    guard let self else {return}
                    self.localStorage.saveImage(image, to: filename)
                        .sink(receiveCompletion: { _ in }, receiveValue: { })
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
    }
}

