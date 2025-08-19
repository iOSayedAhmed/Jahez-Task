//
//  DomainError.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

// MARK: - Domain Errors
enum DomainError: Error, LocalizedError {
    case networkError(Error)
    case cacheError(String)
    case noData
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let networkError):
            return networkError.localizedDescription
        case .cacheError(let message):
            return "Cache error: \(message)"
        case .noData:
            return "No data available"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
