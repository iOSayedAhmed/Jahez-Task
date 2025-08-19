//
//  SearchBarView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct SearchBarView: View {
    let searchText: String
    let onSearchTextChanged: (String) -> Void
    
    @State private var internalSearchText: String = ""
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search movies...", text: $internalSearchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: internalSearchText) { newValue in
                        onSearchTextChanged(newValue)
                    }
                
                if !internalSearchText.isEmpty {
                    Button(action: {
                        internalSearchText = ""
                        onSearchTextChanged("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .onAppear {
            internalSearchText = searchText
        }
    }
}
