//
//  MovieDBTarget.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 13/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import Moya

enum MovieDB {
    case mostPopular(page: Int)
    case topRated(page: Int)
    case mostRecent(page: Int)
    case freeSearch(query: String, page: Int)
}

extension MovieDB : TargetType {
    var baseURL: URL {
        guard let url = URL(string: Consts.queryBaseURL) else { fatalError("base url cound not be configured.")}
        return url
    }
    
    var path: String {
        
        switch self {
        case .mostPopular(_):
            return Consts.mostPopularMoviesURL
        case .topRated(_):
            return Consts.topRatedMoviesURL
        case .mostRecent(_):
            return Consts.mostRecentReleasedMoviesURL
        case .freeSearch(let query, _):
            return Consts.withKeywordURL(query: query)
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .mostPopular(let page):
            return .requestParameters(
                parameters: [
                    "api_key": Consts.apiKey,
                    "language": "en-US",
                    "sort_by": "popularity.desc",
                    "include_adult": "false",
                    "page": "\(page)"
                ], encoding: URLEncoding.default)
        case .topRated(let page):
            return .requestParameters(
                parameters: [
                    "api_key": Consts.apiKey,
                    "language": "en-US",
                    "sort_by": "vote_average.desc",
                    "include_adult": "false",
                    "page": "\(page)"
                ], encoding: URLEncoding.default)
        case .mostRecent(let page):
            return .requestParameters(
                parameters: [
                    "api_key": Consts.apiKey,
                    "language": "en-US",
                    "sort_by": "release_date.desc",
                    "include_adult": "false",
                    "page": "\(page)"
                ], encoding: URLEncoding.default)
        case .freeSearch(let query, let page):
            return .requestParameters(
                parameters: [
                    "api_key": Consts.apiKey,
                    "language": "en-US",
                    "query": query,
                    "include_adult": "false",
                    "page": "\(page)"
                ], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
