//
//  FileManagerStorage.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation
import Combine
import UIKit

final class FileManagerStorage: LocalStorageProtocol {
    static let shared = FileManagerStorage()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let imagesDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        imagesDirectory = documentsDirectory.appendingPathComponent("Images")
        
        // Create images directory if it doesn't exist
        createImagesDirectoryIfNeeded()
    }
    
    private func createImagesDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - JSON Data Storage (Your existing methods)
    
    private func fileURL(for fileName: String) -> URL {
        return documentsDirectory.appendingPathComponent("\(fileName).json")
    }
    
    func save<T: Codable>(_ object: T, to fileName: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            do {
                let data = try JSONEncoder().encode(object)
                let url = self.fileURL(for: fileName)
                try data.write(to: url)
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.saveFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func load<T: Codable>(_ type: T.Type, from fileName: String) -> AnyPublisher<T, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            do {
                let url = self.fileURL(for: fileName)
                let data = try Data(contentsOf: url)
                let object = try JSONDecoder().decode(type, from: data)
                promise(.success(object))
            } catch {
                promise(.failure(LocalStorageError.loadFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(fileName: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            do {
                let url = self.fileURL(for: fileName)
                if self.fileManager.fileExists(atPath: url.path) {
                    try self.fileManager.removeItem(at: url)
                }
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.deleteFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func exists(fileName: String) -> Bool {
        let url = fileURL(for: fileName)
        return fileManager.fileExists(atPath: url.path)
    }
    
    // MARK: - Image Storage
    
    private func imageURL(for fileName: String) -> URL {
        return imagesDirectory.appendingPathComponent("\(fileName).jpg")
    }
    
    func saveImage(_ image: UIImage, to fileName: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            DispatchQueue.global(qos: .utility).async {
                do {
                    guard let data = image.jpegData(compressionQuality: 0.8) else {
                        promise(.failure(LocalStorageError.imageCompressionFailed))
                        return
                    }
                    
                    let url = self.imageURL(for: fileName)
                    try data.write(to: url)
                    
                    DispatchQueue.main.async {
                        promise(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(LocalStorageError.saveFailed(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadImage(from fileName: String) -> UIImage? {
        let url = imageURL(for: fileName)
        
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func deleteImage(fileName: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            do {
                let url = self.imageURL(for: fileName)
                if self.fileManager.fileExists(atPath: url.path) {
                    try self.fileManager.removeItem(at: url)
                }
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.deleteFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func imageExists(fileName: String) -> Bool {
        let url = imageURL(for: fileName)
        return fileManager.fileExists(atPath: url.path)
    }
    
    // MARK: - Cache Management (NEW)
    
    func getCacheSize() -> Int64 {
        let jsonSize = getDirectorySize(documentsDirectory)
        let imageSize = getDirectorySize(imagesDirectory)
        return jsonSize + imageSize
    }
    
    func clearAllCache() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalStorageError.unknown))
                return
            }
            
            DispatchQueue.global(qos: .utility).async {
                do {
                    // Get all JSON files in documents directory
                    let jsonFiles = try self.fileManager.contentsOfDirectory(at: self.documentsDirectory, includingPropertiesForKeys: nil)
                        .filter { $0.pathExtension == "json" }
                    
                    // Delete JSON files
                    for file in jsonFiles {
                        try self.fileManager.removeItem(at: file)
                    }
                    
                    // Delete images directory and recreate it
                    if self.fileManager.fileExists(atPath: self.imagesDirectory.path) {
                        try self.fileManager.removeItem(at: self.imagesDirectory)
                    }
                    self.createImagesDirectoryIfNeeded()
                    
                    DispatchQueue.main.async {
                        promise(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(LocalStorageError.deleteFailed(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCachedFilesCount() -> Int {
        let jsonFiles = (try? fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil))?.filter { $0.pathExtension == "json" }.count ?? 0
        let imageFiles = (try? fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil))?.count ?? 0
        return jsonFiles + imageFiles
    }
    
    private func getDirectorySize(_ directory: URL) -> Int64 {
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.fileSizeKey]) else {
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
}
