//
//  CachedImage.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct CachedImage: View {
    let url: String
    let contentMode: ContentMode
    
    init(url: String, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        CachedAsyncImage(url: url) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
        }
    }
}
