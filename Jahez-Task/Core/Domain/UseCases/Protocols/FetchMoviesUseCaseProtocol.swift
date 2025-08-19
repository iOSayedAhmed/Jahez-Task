//
//  FetchMoviesUseCaseProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol FetchMoviesUseCaseProtocol {
    func execute(page: Int, forceRefresh: Bool) -> AnyPublisher<MoviesPage, DomainError>
}
