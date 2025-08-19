//
//  ImageCacheManager.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation
import UIKit
import Combine

final class ImageCacheManager: ImageCacheProtocol {
    static let shared = ImageCacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let memoryCache = NSCache<NSString, UIImage>()
    private let downloadQueue = DispatchQueue(label: "image.download.queue", qos: .utility)
    private var activeDownloads: [String: AnyPublisher<UIImage?, Never>] = [:]
    
    private init() {
        // Create cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        createCacheDirectoryIfNeeded()
        setupMemoryCache()
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func setupMemoryCache() {
        memoryCache.countLimit = 100 // Limit to 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Clear memory cache when app receives memory warning
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.memoryCache.removeAllObjects()
        }
    }
    
    // MARK: - Public Methods
    
    func getImage(for url: String) -> AnyPublisher<UIImage?, Never> {
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: url as NSString) {
            return Just(cachedImage).eraseToAnyPublisher()
        }
        
        // Check disk cache
        if let diskImage = loadImageFromDisk(url: url) {
            // Store in memory cache for faster access
            memoryCache.setObject(diskImage, forKey: url as NSString)
            return Just(diskImage).eraseToAnyPublisher()
        }
        
        // Check if download is already in progress
        if let existingDownload = activeDownloads[url] {
            return existingDownload
        }
        
        // Download image
        let downloadPublisher = downloadImage(from: url)
            .handleEvents(
                receiveCompletion: { [weak self] _ in
                    self?.activeDownloads.removeValue(forKey: url)
                }
            )
            .share()
            .eraseToAnyPublisher()
        
        activeDownloads[url] = downloadPublisher
        return downloadPublisher
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        // Cache in memory
        memoryCache.setObject(image, forKey: url as NSString)
        
        // Cache on disk
        saveImageToDisk(image: image, url: url)
    }
    
    func clearCache() {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
        
        // Clear active downloads
        activeDownloads.removeAll()
    }
    
    func getCacheSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let url as URL in enumerator {
            if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    // MARK: - Private Methods
    
    private func downloadImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        guard let url = URL(string: urlString) else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: downloadQueue)
            .map { data, _ in
                UIImage(data: data)
            }
            .handleEvents(receiveOutput: { [weak self] image in
                if let image = image {
                    self?.cacheImage(image, for: urlString)
                }
            })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func saveImageToDisk(image: UIImage, url: String) {
        let filename = createFilename(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        DispatchQueue.global(qos: .utility).async {
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
            }
        }
    }
    
    private func loadImageFromDisk(url: String) -> UIImage? {
        let filename = createFilename(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func createFilename(from url: String) -> String {
        // Create a safe filename from URL
        let hash = url.hash
        return "\(abs(hash)).jpg"
    }
}
