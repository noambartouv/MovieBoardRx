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
        case .mostPopular(_), .mostRecent(_), .topRated(_):
            return Consts.searchMoviesByDiscover
        case .freeSearch(_):
            return Consts.searchMovieByKeyword
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        
        var params = [
            "api_key": Consts.apiKey,
            "language": "en-US",
            "include_adult": "false",]
        
        switch self {
        case .mostPopular(let page):
            params["sort_by"] = "popularity.desc"
            params["page"] = "\(page)"
        case .topRated(let page):
            params["sort_by"] = "vote_average.desc"
            params["page"] = "\(page)"
        case .mostRecent(let page):
            params["sort_by"] = "release_date.desc"
            params["page"] = "\(page)"
        case .freeSearch(let query, let page):
            params["query"] = query
            params["page"] = "\(page)"
        }
        
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
