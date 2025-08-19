//
//  CoordinatedNavigationView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            createMoviesView()
                .navigationDestination(for: AppCoordinator.Destination.self) { destination in
                    switch destination {
                    case .movieDetails(let id):
                        createMovieDetailsView(movieId: id)
                    }
                }
        }
        .environmentObject(coordinator)
    }
    
    private func createMoviesView() -> some View {
        let viewModel = MoviesViewModel(coordinator: coordinator)
        return MoviesView(viewModel: viewModel)
    }
    
    private func createMovieDetailsView(movieId: String) -> some View {
        guard let id = Int(movieId) else {
            return AnyView(Text("Invalid Movie ID"))
        }
        let viewModel = MovieDetailsViewModel(coordinator: coordinator)
        return AnyView(MovieDetailsView(viewModel: viewModel, movieId: id))
    }
}
