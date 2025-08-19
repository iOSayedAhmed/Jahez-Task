//
//  DataMapper.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation

protocol DataMapper {
    associatedtype NetworkModel
    associatedtype DomainModel
    
    static func toDomain(_ networkModel: NetworkModel) -> DomainModel
    static func toNetwork(_ domainModel: DomainModel) -> NetworkModel
}
