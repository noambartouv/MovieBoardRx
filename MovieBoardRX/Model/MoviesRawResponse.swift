//
//  MoviesResponse.swift
//  MovieBoard
//
//  Created by Noam Bar-Touv on 28/07/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation

public struct MoviesRawResponse: Codable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [MovieRawData]
}
