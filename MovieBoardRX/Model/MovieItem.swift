//
//  MovieItem.swift
//  MovieBoard
//
//  Created by Noam Bar-Touv on 29/07/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

public struct MovieItem {
    
    let title: String
    var image: Driver<UIImage?>
    let imageUrl: String?
    let overview: String
    let voteAverageScore: Double
    let language: String
    let releaseDate: String
    
    private let _setImage = BehaviorSubject<UIImage?>(value: nil)
    
    func setImage(newImage: UIImage) {
        _setImage.onNext(newImage)
    }
    
    init(movieRawData: MovieRawData) {
        self.title = movieRawData.title
        self.imageUrl = movieRawData.poster_path
        self.overview = movieRawData.overview
        self.voteAverageScore = movieRawData.vote_average
        self.language = movieRawData.original_language
        self.releaseDate = movieRawData.release_date
        
        self.image = _setImage
            .asDriver()
    }
    
    static func fromBulk(movieRawData: [MovieRawData]) -> [MovieItem] {
        var array = [MovieItem]()
        for movie in movieRawData {
            array.append(MovieItem(movieRawData: movie))
        }
        return array
    }
}
