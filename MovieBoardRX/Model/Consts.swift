//
//  Consts.swift
//  MovieBoard
//
//  Created by Noam Bar-Touv on 28/07/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import UIKit

struct Consts {
    
    static let imageAspectRation: CGFloat = 1.5027027027 // Width * aspectRatio = Height
    static let minAmountOfAdditonalCachedMovies = 18
    
    
    static let apiKey: String = "b7364d4438c755310cda77571ad8f84a"
    static let queryBaseURL: String = "https://api.themoviedb.org/3"
    static let imageBaseURL: String = "https://image.tmdb.org/t/p/w185"
    
    // URL paths
    static let searchMoviesByDiscover: String = "/discover/movie"
    static let searchMovieByKeyword: String = "/search/movie"
    
}
