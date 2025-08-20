//
//  MoviesView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//


import SwiftUI
import Combine

// MARK: - Movies View
struct MoviesView: View {
    @StateObject private var viewModel: MoviesViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: MoviesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBarView(
                    searchText: viewModel.state.searchText,
                    onSearchTextChanged: viewModel.updateSearchText
                )
                
                GenresView(
                    genres: viewModel.state.genres,
                    selectedGenre: viewModel.state.selectedGenre,
                    onGenreSelected: viewModel.selectGenre
                )
                
                contentView
            }
            .navigationTitle("Watch New Movies")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if viewModel.state.isFirstLuanch {
                viewModel.loadMovies()
            }
        }
        .refreshable {
            viewModel.refreshMovies()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.state.isLoading {
            LoadingView()
        } else if viewModel.state.shouldShowNoResults {
            NoResultsView()
        } else if viewModel.state.shouldShowMovies {
            moviesGridView
        } else {
            EmptyView()
        }
    }
    
    private var moviesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.state.filteredMovies) { movie in
                    MovieCardView(movie: movie) {
                        viewModel.showMovieDetails(id: movie.id)
                    }
                    .onAppear {
                        if movie == viewModel.state.filteredMovies.last {
                            viewModel.loadMoreMovies()
                        }
                    }
                }
                
                if viewModel.state.isLoadingMore {
                    ProgressView()
                        .gridCellColumns(2)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }
}
