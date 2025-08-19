//
//  MoviesViewModel.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//
import Foundation
import Combine

protocol MoviesViewModelProtocol: ObservableObject {
    var state: MoviesViewState { get }
    
    func loadMovies()
    func loadMoreMovies()
    func refreshMovies()
    func selectGenre(_ genre: Genre?)
    func updateSearchText(_ text: String)
    func retryAfterError()
}

final class MoviesViewModel: ObservableObject {
    @Published private(set) var state = MoviesViewState()
    
    // Injected Dependencies
    @Injected private var fetchMoviesUseCase: FetchMoviesUseCaseProtocol
    @Injected private var fetchGenresUseCase: FetchGenresUseCaseProtocol
    @Injected private var filterMoviesUseCase: FilterMoviesUseCaseProtocol
    
    private let coordinator: MoviesCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    init(coordinator: MoviesCoordinatorProtocol) {
        self.coordinator = coordinator
        setupSearchDebounce()
    }
    
    // MARK: - Public Methods
    func loadMovies() {
        guard !state.isLoading else { return }
        
        state.isLoading = true
        state.errorMessage = nil
        state.currentPage = 1
        state.movies.removeAll()
        
        let moviesPublisher = fetchMoviesUseCase.execute(page: 1, forceRefresh: false)
        let genresPublisher = fetchGenresUseCase.execute(forceRefresh: false)
        
        Publishers.CombineLatest(moviesPublisher, genresPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.state.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] moviesPage, genres in
                    self?.handleMoviesAndGenresLoaded(moviesPage: moviesPage, genres: genres)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMoreMovies() {
        guard !state.isLoadingMore && !state.isLoading && state.hasMorePages else { return }
        
        state.isLoadingMore = true
        let nextPage = state.currentPage + 1
        
        fetchMoviesUseCase.execute(page: nextPage, forceRefresh: false)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.state.isLoadingMore = false
                    
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] moviesPage in
                    self?.handleMoreMoviesLoaded(moviesPage: moviesPage)
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshMovies() {
        state.currentPage = 1
        state.movies.removeAll()
        state.hasMorePages = true
        loadMovies()
    }
    
    func selectGenre(_ genre: Genre?) {
        state.selectedGenre = genre
        filterMovies()
    }
    
    func updateSearchText(_ text: String) {
        state.searchText = text
        searchSubject.send(text)
    }
    
    func retryAfterError() {
        state.errorMessage = nil
        loadMovies()
    }
    
    func showMovieDetails(id: Int) {
        coordinator.showMovieDetail(id: "\(id)")
    }
    
    // MARK: - Private Methods
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterMovies()
            }
            .store(in: &cancellables)
    }
    
    private func handleMoviesAndGenresLoaded(moviesPage: MoviesPage, genres: [Genre]) {
        state.movies = moviesPage.movies
        state.genres = genres
        state.currentPage = moviesPage.page
        state.hasMorePages = moviesPage.hasMorePages
        filterMovies()
    }
    
    private func handleMoreMoviesLoaded(moviesPage: MoviesPage) {
        state.movies.append(contentsOf: moviesPage.movies)
        state.currentPage = moviesPage.page
        state.hasMorePages = moviesPage.hasMorePages
        filterMovies()
    }
    
    private func filterMovies() {
        let filtered = filterMoviesUseCase.execute(
            movies: state.movies,
            selectedGenre: state.selectedGenre,
            searchText: state.searchText
        )
        
        state.filteredMovies = filtered
        state.showNoResults = filtered.isEmpty && (!state.searchText.isEmpty || state.selectedGenre != nil)
    }
    
    private func handleError(_ error: DomainError) {
        state.errorMessage = error.localizedDescription
    }
}
