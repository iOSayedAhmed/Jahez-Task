//
//  FileManagerStorage.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation
import Combine

final class FileManagerStorage: LocalStorageProtocol {
    static let shared = FileManagerStorage()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, 
                                            in: .userDomainMask).first!
    }
    
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
}
