//
//  CachedAsyncImage.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI
import Combine

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var cancellables = Set<AnyCancellable>()
    
    private let url: String
    private let content: (UIImage) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: String,
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(image)
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard !url.isEmpty else { return }
        
        ImageCacheManager.shared.getImage(for: url)
            .sink { loadedImage in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.image = loadedImage
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
}
