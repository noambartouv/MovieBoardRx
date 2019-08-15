//
//  MovieDBTarget.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 13/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import Moya

class ImagesTarget {
    var posterUrl: String
    
    init(posterUrl: String) {
        self.posterUrl = posterUrl
    }
}

extension ImagesTarget : TargetType {
    var baseURL: URL {
        guard let url = URL(string: Consts.imageBaseURL) else { fatalError("base url cound not be configured.")}
        return url
    }
    
    var path: String {
        return posterUrl
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
