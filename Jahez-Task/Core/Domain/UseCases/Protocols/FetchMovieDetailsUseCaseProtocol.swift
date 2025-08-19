//
//  FetchMovieDetailsUseCaseProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol FetchMovieDetailsUseCaseProtocol {
    func execute(movieId: Int) -> AnyPublisher<MovieDetails, DomainError>
}
