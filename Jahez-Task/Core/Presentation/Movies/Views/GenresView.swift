//
//  GenresView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct GenresView: View {
    let genres: [Genre]
    let selectedGenre: Genre?
    let onGenreSelected: (Genre?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All genres chip
                GenreChipView(
                    title: "All",
                    isSelected: selectedGenre == nil
                ) {
                    onGenreSelected(nil)
                }
                
                ForEach(genres) { genre in
                    GenreChipView(
                        title: genre.name,
                        isSelected: selectedGenre?.id == genre.id
                    ) {
                        onGenreSelected(genre)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}
