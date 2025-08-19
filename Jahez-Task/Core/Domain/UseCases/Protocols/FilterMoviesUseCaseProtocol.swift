//
//  FilterMoviesUseCaseProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Combine

protocol FilterMoviesUseCaseProtocol {
    func execute(movies: [Movie], selectedGenre: Genre?, searchText: String) -> [Movie]
}
