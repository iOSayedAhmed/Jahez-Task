//
//  MoviesViewState.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//


struct MoviesViewState: Equatable {
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    var genres: [Genre] = []
    var selectedGenre: Genre? = nil
    var searchText: String = ""
    var isLoading: Bool = false
    var isFirstLuanch: Bool = true
    var isLoadingMore: Bool = false
    var errorMessage: String? = nil
    var currentPage: Int = 1
    var hasMorePages: Bool = true
    var showNoResults: Bool = false
    
    var shouldShowMovies: Bool {
        !isLoading && !filteredMovies.isEmpty
    }
    
    var shouldShowNoResults: Bool {
        !isLoading && filteredMovies.isEmpty && (!searchText.isEmpty || selectedGenre != nil)
    }
    
    var shouldShowError: Bool {
        errorMessage != nil
    }
    
    var shouldCallApi: Bool {
        isFirstLuanch
    }
}
