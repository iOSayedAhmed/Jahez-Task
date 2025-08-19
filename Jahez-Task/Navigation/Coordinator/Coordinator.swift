//
//  SwiftUICoordinator.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject, MoviesCoordinatorProtocol {
    @Published var path = NavigationPath()
    @Published var selectedMovieID: String?
    
    enum Destination: Hashable {
        case movieDetails(id: String)
    }
    
    // MARK: - MoviesCoordinatorProtocol
    func showMovieDetail(id: String) {
        selectedMovieID = id
        path.append(Destination.movieDetails(id: id))
    }
    
    func goBack(animated: Bool = true) {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func getSelectedMovieID() -> String? {
        return selectedMovieID
    }
    
    // MARK: - Navigation Helpers
    func popToRoot() {
        path.removeLast(path.count)
        selectedMovieID = nil
    }
    
    func goToMovieDetails(id: Int) {
        showMovieDetail(id: "\(id)")
    }
}
