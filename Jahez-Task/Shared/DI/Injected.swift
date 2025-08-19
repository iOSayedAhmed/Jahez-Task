//
//  Injected.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T
    
    init() {
        self.wrappedValue = DIContainer.shared.resolve(T.self)
    }
}
