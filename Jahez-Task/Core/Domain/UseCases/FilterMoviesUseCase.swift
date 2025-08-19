//
//  FilterMoviesUseCase.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Combine

final class FilterMoviesUseCase: FilterMoviesUseCaseProtocol {
    func execute(movies: [Movie], selectedGenre: Genre?, searchText: String) -> [Movie] {
        var filteredMovies = movies
        
        // Filter by genre if selected
        if let selectedGenre = selectedGenre {
            filteredMovies = filteredMovies.filter { movie in
                movie.genreIds.contains(selectedGenre.id)
            }
        }
        
        // Filter by search text if provided
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            filteredMovies = filteredMovies.filter { movie in
                movie.title.localizedCaseInsensitiveContains(trimmedSearchText)
            }
        }
        
        return filteredMovies
    }
}
