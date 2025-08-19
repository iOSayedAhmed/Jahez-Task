//
//  SplashScreenView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

// MARK: - Splash Screen View
struct SplashView: View {
    @State private var isVideoPlaying = false
    @State private var showProgressBar = false
    @State private var progress: Double = 0.0
    @State private var navigateToApp = false
    
    let onSplashComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.splashBackground
                .ignoresSafeArea()
            
            // Video Player (if video file exists)
            if let videoURL = getVideoURL() {
                VideoPlayerView(
                    url: videoURL,
                    isPlaying: $isVideoPlaying,
                    onVideoEnded: {
                        startProgressAnimation()
                    }
                )
                .ignoresSafeArea()
            } else {
                // Fallback: Logo animation if no video
                logoAnimationView
            }
            
            // Progress bar overlay
            VStack {
                Spacer()
                
                if showProgressBar {
                    progressBarView
                        .padding(.horizontal, 40)
                        .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            setupSplash()
        }
        .fullScreenCover(isPresented: $navigateToApp) {
            // Navigate to your main app
            CoordinatorView() // Your main app view
        }
    }
    
    // MARK: - Logo Animation (Fallback)
    private var logoAnimationView: some View {
        VStack(spacing: 30) {
            // App Logo or Title
            VStack(spacing: 10) {
                Image(systemName: "film.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(progress > 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                Text("Jahez Movies")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(progress > 0.3 ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: progress)
            }
            
            // Subtitle
            Text("Discover Amazing Movies")
                .font(.title3)
                .foregroundColor(.gray)
                .opacity(progress > 0.6 ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1.0).delay(1.0), value: progress)
        }
    }
    
    // MARK: - Progress Bar
    private var progressBarView: some View {
        VStack(spacing: 15) {
            // Loading text
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.white)
                .opacity(0.8)
            
            // Progress bar
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                .frame(height: 4)
                .background(Color.white.opacity(0.3))
                .cornerRadius(2)
        }
    }
    
    // MARK: - Setup Methods
    private func setupSplash() {
        if getVideoURL() != nil {
            // Start video
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isVideoPlaying = true
            }
            
            // Auto navigate To App after 4.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                completeSplash()
            }
        } else {
            // No video, start logo animation immediately
            startProgressAnimation()
        }
    }
}
extension SplashView {
    private func startProgressAnimation() {
        showProgressBar = true
        
        withAnimation(.easeInOut(duration: 2.0)) {
            progress = 1.0
        }
        
        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            completeSplash()
        }
    }
    
    private func completeSplash() {
        withAnimation(.easeInOut(duration: 0.5)) {
            navigateToApp = true
        }
        onSplashComplete()
    }
    
    private func getVideoURL() -> URL? {
        return Bundle.main.url(forResource: "jahez", withExtension: "mp4")
    }
}
