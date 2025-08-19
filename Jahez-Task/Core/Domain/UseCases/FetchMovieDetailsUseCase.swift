//
//  FetchMovieDetailsUseCase.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class FetchMovieDetailsUseCase: FetchMovieDetailsUseCaseProtocol {
    private let repository: MovieDetailsRepositoryProtocol
    
    init(repository: MovieDetailsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(movieId: Int) -> AnyPublisher<MovieDetails, DomainError> {
        return repository.fetchMovieDetails(id: movieId)
    }
}
