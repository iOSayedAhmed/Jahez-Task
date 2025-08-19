//
//  MovieDetailsRepositoryProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation
import Combine

protocol MovieDetailsRepositoryProtocol {
    func fetchMovieDetails(id: Int) -> AnyPublisher<MovieDetails, DomainError>
}
