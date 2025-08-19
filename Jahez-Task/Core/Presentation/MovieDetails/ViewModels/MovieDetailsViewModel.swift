//
//  MovieDetailsViewModel.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//
import Foundation
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published private(set) var state = MovieDetailsViewState()
    
    // Injected Dependencies
    @Injected private var fetchMovieDetailsUseCase: FetchMovieDetailsUseCaseProtocol
    
    private let coordinator: MoviesCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: MoviesCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func loadMovieDetails(id: Int) {
        guard !state.isLoading else { return }
        
        state.isLoading = true
        state.errorMessage = nil
        
        fetchMovieDetailsUseCase.execute(movieId: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.state.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.state.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] movieDetails in
                    self?.state.movieDetails = movieDetails
                }
            )
            .store(in: &cancellables)
    }
    
    func retryAfterError() {
        guard let movieId = state.movieDetails?.id else { return }
        state.errorMessage = nil
        loadMovieDetails(id: movieId)
    }
    
    func goBack() {
        coordinator.goBack(animated: true)
    }
    
    func shareMovie() -> [Any] {
        guard let movie = state.movieDetails else { return [] }
        
        var items: [Any] = [movie.titleWithYear]
        
        if !movie.posterURL.isEmpty {
            items.append(movie.posterURL)
        }
        
        return items
    }
}

