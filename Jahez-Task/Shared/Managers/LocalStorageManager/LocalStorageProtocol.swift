//
//  LocalStorageProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Combine

protocol LocalStorageProtocol {
    func save<T: Codable>(_ object: T, to fileName: String) -> AnyPublisher<Void, Error>
    func load<T: Codable>(_ type: T.Type, from fileName: String) -> AnyPublisher<T, Error>
    func delete(fileName: String) -> AnyPublisher<Void, Error>
    func exists(fileName: String) -> Bool
}
