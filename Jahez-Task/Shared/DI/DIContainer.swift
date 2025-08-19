//
//  DIContainer 2.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    
    private init() {
        setupDependencies()
    }
    
    // MARK: - Register & Resolve
    
    func register<T>(_ type: T.Type, service: T) {
        let key = String(describing: type)
        services[key] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("Service of type \(T.self) not registered")
        }
        return service
    }
    
    // MARK: - Setup All Dependencies
    
    private func setupDependencies() {
        let networkManager = NetworkManager.shared
        let localStorage = FileManagerStorage.shared
        
        register(NetworkManagerProtocol.self, service: networkManager)
        register(LocalStorageProtocol.self, service: localStorage)
        
        // Repositories
        let moviesRepository = MoviesRepository(
            networkManager: networkManager,
            localStorage: localStorage
        )
        let genresRepository = GenresRepository(
            networkManager: networkManager,
            localStorage: localStorage
        )
        let movieDetailsRepository = MovieDetailsRepository(
            networkManager: networkManager
        )
        
        register(MoviesRepositoryProtocol.self, service: moviesRepository)
        register(GenresRepositoryProtocol.self, service: genresRepository)
        register(MovieDetailsRepositoryProtocol.self, service: movieDetailsRepository)
        
        // Use Cases
        let fetchMoviesUseCase = FetchMoviesUseCase(repository: moviesRepository)
        let fetchGenresUseCase = FetchGenresUseCase(repository: genresRepository)
        let fetchMovieDetailsUseCase = FetchMovieDetailsUseCase(repository: movieDetailsRepository)
        let filterMoviesUseCase = FilterMoviesUseCase()
        
        register(FetchMoviesUseCaseProtocol.self, service: fetchMoviesUseCase)
        register(FetchGenresUseCaseProtocol.self, service: fetchGenresUseCase)
        register(FetchMovieDetailsUseCaseProtocol.self, service: fetchMovieDetailsUseCase)
        register(FilterMoviesUseCaseProtocol.self, service: filterMoviesUseCase)
    }
}
