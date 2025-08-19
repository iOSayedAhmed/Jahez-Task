//
//  LocalStorageError.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation

enum LocalStorageError: Error, LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case fileNotFound
    case imageCompressionFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found"
        case .imageCompressionFailed:
            return "Failed to compress image"
        case .unknown:
            return "Unknown storage error"
        }
    }
}
