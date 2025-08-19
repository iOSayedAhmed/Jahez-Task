//
//  FetchGenresUseCase.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

final class FetchGenresUseCase: FetchGenresUseCaseProtocol {
    private let repository: GenresRepositoryProtocol
    
    init(repository: GenresRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(forceRefresh: Bool = false) -> AnyPublisher<[Genre], DomainError> {
        if forceRefresh {
            return repository.fetchGenres()
        }
        
        return repository.fetchGenres()
            .catch { [weak self] error -> AnyPublisher<[Genre], DomainError> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // If network fails, try to return cached data
                return self.repository.fetchCachedGenres()
            }
            .eraseToAnyPublisher()
    }
}
