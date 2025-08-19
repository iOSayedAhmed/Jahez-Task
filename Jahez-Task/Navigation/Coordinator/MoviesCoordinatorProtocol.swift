//
//  MoviesCoordinatorProtocol.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

protocol MoviesCoordinatorProtocol: AnyObject {
    func showMovieDetail(id: String)
    func goBack(animated: Bool)
    func getSelectedMovieID() -> String?
}
