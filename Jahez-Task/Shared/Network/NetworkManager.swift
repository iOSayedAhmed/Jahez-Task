//
//  NetworkManager.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import Foundation
import Combine


// MARK: - Network Manager Protocol
protocol NetworkManagerProtocol {
    func execute<T: Codable>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}

// MARK: - Network Manager Implementation
final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func execute<T: Codable>(_ request: APIRequest, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        do {
            let urlRequest = try request.asURLRequest()
            
            return session.dataTaskPublisher(for: urlRequest)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.invalidResponse
                    }
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        return data
                    case 401:
                        throw NetworkError.unauthorized
                    case 400...499, 500...599:
                        throw NetworkError.serverError(httpResponse.statusCode)
                    default:
                        throw NetworkError.invalidResponse
                    }
                }
                .decode(type: T.self, decoder: decoder)
                .mapError { error -> NetworkError in
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else if error is DecodingError {
                        return .decodingError(error)
                    } else {
                        return .networkError(error)
                    }
                }
                .eraseToAnyPublisher()
                
        } catch {
            return Fail(error: NetworkError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
}


// MARK: - Movies API Requests
enum MoviesAPIRequest: APIRequest {
    case getMovies(page: Int)
    case getGenres
    case getMovieDetails(id: Int)
    
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .getMovies(let page):
            return "discover/movie?include_adult=false&sort_by=popularity.desc&page=\(page)"
        case .getGenres:
            return "genre/movie/list"
        case .getMovieDetails(let id):
            return "movie/\(id)"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getMovies(let page):
            return [
                "api_key": APIConfiguration.apiKey,
                "page": page
            ]
        case .getGenres, .getMovieDetails:
            return [
                "api_key": APIConfiguration.apiKey 
            ]
        }
    }
    
    var body: Data? {
        return nil
    }
}

// MARK: - Network Response Models
struct MoviesResponse: Codable {
    let page: Int
    let results: [MovieResponse]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieResponse: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let genreIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
    }
}

struct GenresResponse: Codable {
    let genres: [GenreResponse]
}

struct GenreResponse: Codable {
    let id: Int
    let name: String
}

struct MovieDetailsResponse: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let budget: Int
    let revenue: Int
    let status: String
    let homepage: String?
    let genres: [GenreResponse]
    let spokenLanguages: [SpokenLanguageResponse]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, budget, revenue, status, homepage, genres
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case spokenLanguages = "spoken_languages"
    }
}

struct SpokenLanguageResponse: Codable {
    let englishName: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case name
    }
}
