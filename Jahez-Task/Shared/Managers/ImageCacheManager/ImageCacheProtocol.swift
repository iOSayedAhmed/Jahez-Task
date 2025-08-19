//
//  ImageCacheProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import Foundation
import UIKit
import Combine

protocol ImageCacheProtocol {
    func getImage(for url: String) -> AnyPublisher<UIImage?, Never>
    func cacheImage(_ image: UIImage, for url: String)
    func clearCache()
    func getCacheSize() -> Int64
}
