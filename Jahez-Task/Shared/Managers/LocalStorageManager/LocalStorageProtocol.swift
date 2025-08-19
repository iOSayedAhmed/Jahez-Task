//
//  LocalStorageProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Combine
import UIKit

protocol LocalStorageProtocol {
    // JSON Data Storage
    func save<T: Codable>(_ object: T, to fileName: String) -> AnyPublisher<Void, Error>
    func load<T: Codable>(_ type: T.Type, from fileName: String) -> AnyPublisher<T, Error>
    func delete(fileName: String) -> AnyPublisher<Void, Error>
    func exists(fileName: String) -> Bool
    
    func saveImage(_ image: UIImage, to fileName: String) -> AnyPublisher<Void, Error>
    func loadImage(from fileName: String) -> UIImage?
    func deleteImage(fileName: String) -> AnyPublisher<Void, Error>
    func imageExists(fileName: String) -> Bool
    
    func getCacheSize() -> Int64
    func clearAllCache() -> AnyPublisher<Void, Error>
    func getCachedFilesCount() -> Int
}
