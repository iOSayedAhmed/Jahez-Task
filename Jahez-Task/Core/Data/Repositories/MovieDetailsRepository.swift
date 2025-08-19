//
//  MovieDetailsRepository.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class MovieDetailsRepository: MovieDetailsRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, DomainError> {
        let request = MoviesAPIRequest.getMovieDetails(id: id)
        
        return networkManager.execute(request, responseType: MovieDetailsResponse.self)
            .map(MovieDetailsMapper.toDomain)
            .mapError { DomainError.networkError($0) }
            .eraseToAnyPublisher()
    }
}
