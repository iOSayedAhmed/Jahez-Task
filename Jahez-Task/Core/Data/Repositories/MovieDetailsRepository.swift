//
//  MovieDetailsRepository.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation
import Combine
import UIKit

final class MovieDetailsRepository: MovieDetailsRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let localStorage: LocalStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkManager: NetworkManagerProtocol, localStorage: LocalStorageProtocol) {
        self.networkManager = networkManager
        self.localStorage = localStorage
    }
    
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, DomainError> {
        let request = MoviesAPIRequest.getMovieDetails(id: id)
        
        return networkManager.execute(request, responseType: MovieDetailsResponse.self)
            .map(MovieDetailsMapper.toDomain)
            .handleEvents(receiveOutput: { [weak self] movieDetails in
                // Cache movie details and poster image
                self?.cacheMovieDetailsWithImage(movieDetails)
            })
            .catch { [weak self] error -> AnyPublisher<MovieDetails, DomainError> in
                // If network fails, try to return cached data
                guard let self = self else {
                    return Fail(error: DomainError.networkError(error)).eraseToAnyPublisher()
                }
                
                return self.fetchCachedMovieDetails(id: id)
                    .eraseToAnyPublisher()
            }
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedMovieDetails(id: Int) -> AnyPublisher<MovieDetails, DomainError> {
        let filename = StorageKeys.movieDetails(id: id)
        
        return localStorage.load(MovieDetails.self, from: filename)
            .mapError { _ in DomainError.cacheError("Movie details not found in cache") }
            .eraseToAnyPublisher()
    }
    
    private func cacheMovieDetailsWithImage(_ movieDetails: MovieDetails) {
        // Cache movie details
        let filename = StorageKeys.movieDetails(id: movieDetails.id)
        localStorage.save(movieDetails, to: filename)
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &cancellables)
        
        // Cache movie poster image if not already cached
        let imageFilename = StorageKeys.movieImage(url: movieDetails.posterURL)
        
        guard !movieDetails.posterURL.isEmpty,
              let url = URL(string: movieDetails.posterURL),
              !localStorage.imageExists(fileName: imageFilename) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    guard let self else {return}
                    // Save image asynchronously
                    self.localStorage.saveImage(image, to: imageFilename)
                        .sink(receiveCompletion: { _ in }, receiveValue: { })
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
    }
}
