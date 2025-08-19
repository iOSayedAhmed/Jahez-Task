//
//  GenreMapper.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

struct GenreMapper: DataMapper {
    typealias NetworkModel = GenreResponse
    typealias DomainModel = Genre
    
    static func toDomain(_ networkModel: GenreResponse) -> Genre {
        return Genre(id: networkModel.id, name: networkModel.name)
    }
    
    static func toNetwork(_ domainModel: Genre) -> GenreResponse {
        return GenreResponse(id: domainModel.id, name: domainModel.name)
    }
}
