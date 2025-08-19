//
//  VideoPlayerView
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI
import AVKit
import AVFoundation

// MARK: - Video Player View
struct VideoPlayerView: UIViewRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    let onVideoEnded: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = UIScreen.main.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        // Store player in context for control
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        // Observe when video ends
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.videoEnded),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
        
        // Update frame on orientation change
        context.coordinator.playerLayer?.frame = UIScreen.main.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onVideoEnded: onVideoEnded)
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        let onVideoEnded: () -> Void
        
        init(onVideoEnded: @escaping () -> Void) {
            self.onVideoEnded = onVideoEnded
        }
        
        @objc func videoEnded() {
            onVideoEnded()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
