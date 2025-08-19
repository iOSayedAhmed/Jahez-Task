//
//  FileManagerStorage+Extenstion.Swift
//  Jahez-Task
//
//  Created by iOSAYed on 19/08/2025.
//


extension FileManagerStorage {
    func createSafeFilename(from url: String) -> String {
        // Create a safe filename from URL
        let hash = abs(url.hashValue)
        return "image_\(hash)"
    }
    
    func createMovieDetailsFilename(for movieId: Int) -> String {
        return "movie_details_\(movieId)"
    }
}