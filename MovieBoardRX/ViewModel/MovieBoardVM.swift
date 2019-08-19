//
//  MovieBoardVM.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 11/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias ImageWithIndex = (UIImage?, Int)

protocol MovieBoardVMing {
    
    // MARK - Input
    var newSearchRequest: PublishSubject<MovieDB> { get }
    var operationOnCurrentSearch: PublishSubject<pageOperations> { get }
    var moviePosterRequest: PublishSubject<Int> { get }

    // MARK - Output
    var items: Driver<[MovieItem]> { get }
    var itemsPageCount: Driver<Int> { get }
    var newImage: Driver<ImageWithIndex> { get }
}

class MovieBoardVM: MovieBoardVMing {
    
    // MARK - Input
    let newSearchRequest =  PublishSubject<MovieDB>()
    let operationOnCurrentSearch = PublishSubject<pageOperations>()
    let moviePosterRequest = PublishSubject<Int>()

    // MARK - Output
    let items: Driver<[MovieItem]>
    let itemsPageCount: Driver<Int>
    let newImage: Driver<ImageWithIndex>
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        // ----------------------------- searches and additional page fetching --------------------------
        
        // movies in cache handling
        items = NetworkService.shared.moviesRawDataStream
            .scan([MovieItem](), accumulator: { (oldState, args) -> [MovieItem] in
                let (movieRawData, isNewSearch) = args
                let newItems: [MovieItem] = MovieItem.fromBulk(movieRawData: movieRawData)
                
                let result: [MovieItem]
                if(isNewSearch) {
                    result = newItems
                } else {
                    result = oldState + newItems
                }
                
                print ("num of results: \(result.count)")
                return result
            })            
            .asDriver()
        
        // page number tracking
        itemsPageCount = operationOnCurrentSearch.scan(1, accumulator: { (oldPageNumber, op) -> Int in
            switch op {
            case .increment:
                return oldPageNumber + 1
            case .reset:
                return 1
            case .doNothing:
                return oldPageNumber
            }
            })
            .asDriver()
            .debug("pageNumber")
        
        let resetPageCount = newSearchRequest.map { _ -> pageOperations in
            return .reset
            }
        
        resetPageCount.bind(to: self.operationOnCurrentSearch)
        
        // movie searches and additional page requests
        let fetchAnotherPage = Observable.combineLatest(newSearchRequest, itemsPageCount.asObservable())
            .filter { $1 != 1 }
            .map { (arg) -> MovieDB in
                let (db, pageNumber) = arg
                switch db {
                case .mostPopular(_):
                    return MovieDB.mostPopular(page: pageNumber)
                case .topRated(_):
                    return MovieDB.topRated(page: pageNumber)
                case .mostRecent(_):
                    return MovieDB.mostRecent(page: pageNumber)
                case .freeSearch(let query, _):
                    return MovieDB.freeSearch(query: query, page: pageNumber)
                }
            }
            .debug("urlTofire")
        
        let initiateMoviesRequest = Observable.merge(newSearchRequest, fetchAnotherPage)
        
        initiateMoviesRequest.bind(to: NetworkService.shared.fetchMovies)
            .disposed(by: disposeBag)
        
    
        // ---------------------------------------- images --------------------------------------------

        // fetch image from external DB
        let iniateImageRequest = Observable.combineLatest(moviePosterRequest, items.asObservable()).map { (index, items) -> TargetWithIndex? in
            if let imageUrl = items[safe: index]?.imageUrl {
                let imageTarget = ImagesTarget(posterUrl: imageUrl)
                return (imageTarget, index)
            } else {
                print("problem fetching image \(index)")
                return nil
            }
        }
        
        iniateImageRequest.bind(to: NetworkService.shared.getImageFromUrl)
            .disposed(by: disposeBag)
        
        // insert image to dataSource
        newImage = Observable.combineLatest(NetworkService.shared.imageStream, items.asObservable()).map { args, _items -> ImageWithIndex? in
            guard let (image, index) = args, let _image = image else { return nil }
            _items[safe: index]?.setImage(newImage: _image)
            return (_image, index)
            }
            .debug("image fetch")
            .filterNil()
            .asDriver()
    }
    
}

enum pageOperations {
    case increment
    case reset
    case doNothing
}
