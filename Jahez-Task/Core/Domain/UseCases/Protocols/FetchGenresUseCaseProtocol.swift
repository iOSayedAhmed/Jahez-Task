//
//  FetchGenresUseCaseProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol FetchGenresUseCaseProtocol {
    func execute(forceRefresh: Bool) -> AnyPublisher<[Genre], DomainError>
}
