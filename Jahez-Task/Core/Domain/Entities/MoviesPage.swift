//
//  MoviesPage.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

struct MoviesPage: Equatable {
    let page: Int
    let movies: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    var hasMorePages: Bool {
        page < totalPages
    }
}
