//
//  MovieDetailsView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct MovieDetailsView: View {
    @StateObject private var viewModel: MovieDetailsViewModel
    private let movieId: Int
    
    init(viewModel: MovieDetailsViewModel, movieId: Int) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.movieId = movieId
    }
    
    var body: some View {
        Group {
            if viewModel.state.isLoading {
                LoadingView()
            }  else if viewModel.state.shouldShowContent {
                movieDetailsContent
            } else {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.loadMovieDetails(id: movieId)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var movieDetailsContent: some View {
        if let movieDetails = viewModel.state.movieDetails {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerView(movieDetails: movieDetails)
                    detailsView(movieDetails: movieDetails)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    private func headerView(movieDetails: MovieDetails) -> some View {
        ZStack(alignment: .top) {
            AsyncImage(url: URL(string: movieDetails.posterURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
            .frame(height: 400)
            .clipped()
            
            // Navigation and share buttons
            HStack {
                Button(action: viewModel.goBack) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 40, height: 40)
                        )
                }
                
                Spacer()
//                ShareLink(items: viewModel.shareMovie()) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .background(
//                            Circle()
//                                .fill(Color.black.opacity(0.3))
//                                .frame(width: 40, height: 40)
//                        )
//                }
            }
            .padding()
            .padding(.top, 40)
        }
    }
    
    private func detailsView(movieDetails: MovieDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Movie poster and basic info
            HStack(alignment: .top, spacing: 16) {
                AsyncImage(url: URL(string: movieDetails.posterURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 120, height: 180)
                .cornerRadius(8)
                .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(movieDetails.titleWithYear)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Text(movieDetails.genreNames)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("\(movieDetails.voteAverage, specifier: "%.1f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("(\(movieDetails.voteCount) votes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Overview
            if !movieDetails.overview.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(movieDetails.overview)
                        .font(.body)
                        .lineSpacing(2)
                }
            }
            
            // Additional details
            VStack(alignment: .leading, spacing: 12) {
                if let homepage = movieDetails.homepage, !homepage.isEmpty {
                    DetailRowView(
                        title: "Homepage",
                        value: homepage,
                        isLink: true
                    )
                }
                
                DetailRowView(title: "Status", value: movieDetails.status)
                DetailRowView(title: "Runtime", value: movieDetails.formattedRuntime)
                DetailRowView(title: "Budget", value: movieDetails.formattedBudget)
                DetailRowView(title: "Revenue", value: movieDetails.formattedRevenue)
                
                if !movieDetails.languageNames.isEmpty {
                    DetailRowView(title: "Languages", value: movieDetails.languageNames)
                }
            }
        }
        .padding()
    }
}
