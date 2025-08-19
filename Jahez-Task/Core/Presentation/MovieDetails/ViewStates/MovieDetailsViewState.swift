//
//  MovieDetailsViewState.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

struct MovieDetailsViewState: Equatable {
    var movieDetails: MovieDetails? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var shouldShowContent: Bool {
        !isLoading && movieDetails != nil
    }
    
    var shouldShowError: Bool {
        errorMessage != nil
    }
}
