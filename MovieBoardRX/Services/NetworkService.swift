//
//  NetworkService.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 12/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RxSwift
import Moya

typealias TargetWithIndex = (ImagesTarget, Int)
typealias isNewSearch = Bool


protocol Networking {
    // MARK - Input
    var fetchMovies: PublishSubject<MovieDB> { get }
    var getImageFromUrl: PublishSubject<TargetWithIndex?> { get }
    
    // MARK - Output
    var moviesRawDataStream: Observable<([MovieRawData], isNewSearch)> { get }
    var imageStream: Observable<ImageWithIndex?> { get }
}

class NetworkService : Networking {
    
    static var shared: NetworkService = NetworkService()
    
    // MARK - Input
    let fetchMovies = PublishSubject<MovieDB>()
    let getImageFromUrl =  PublishSubject<TargetWithIndex?>()
    private let _moviesRawDataStream = PublishSubject<([MovieRawData], isNewSearch)>()
    private let _imageStream = PublishSubject<ImageWithIndex?>()
    
    // MARK - Output
    let moviesRawDataStream: Observable<([MovieRawData], isNewSearch)>
    let imageStream: Observable<ImageWithIndex?>
    private let disposeBag = DisposeBag()
    
    private let movieDBProvider = MoyaProvider<MovieDB>() //(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let imagesProvider = MoyaProvider<ImagesTarget>() //(plugins: [NetworkLoggerPlugin(verbose: true)])
    private let decoder = JSONDecoder()
    
    public init() {
        moviesRawDataStream = _moviesRawDataStream
        imageStream = _imageStream
        
        // movies requests
        let moyaMoviesRequest = fetchMovies
            .flatMap { [weak self] _searchFor -> Observable<(Response, isNewSearch)> in
                guard let self = self else { return Observable.never() }
                
                let request: Single<Response>
                let newSearch: Bool
                
                switch _searchFor {
                case .mostPopular(let page):
                    request = self.movieDBProvider.rx.request(.mostPopular(page: page), callbackQueue: DispatchQueue.main)
                    newSearch = self.isNewSearch(page: page)
                case .topRated(let page):
                    request = self.movieDBProvider.rx.request(.topRated(page: page), callbackQueue: DispatchQueue.main)
                    newSearch = self.isNewSearch(page: page)
                case .mostRecent(let page):
                    request = self.movieDBProvider.rx.request(.mostRecent(page: page), callbackQueue: DispatchQueue.main)
                    newSearch = self.isNewSearch(page: page)
                case .freeSearch(let query, let page):
                    request = self.movieDBProvider.rx.request(.freeSearch(query: query, page: page), callbackQueue: DispatchQueue.main)
                    newSearch = self.isNewSearch(page: page)
                }
                
                return Observable.combineLatest(request.asObservable(), Observable.just(newSearch))
            }
        
        
        let moyaMoviesResponse = moyaMoviesRequest.map { args -> ([MovieRawData], isNewSearch)  in
            let (_response, _isNewSearch) = args
            let moviesResponse = try self.decoder.decode(MoviesRawResponse.self, from: _response.data).results
            
            return (moviesResponse, _isNewSearch)
        }
        
        moyaMoviesResponse.bind(to: _moviesRawDataStream)
            .disposed(by: disposeBag)
        
        
        // image requests
        let moyaFetchImage = getImageFromUrl
            .flatMap { [weak self] args -> Observable<ImageWithIndex> in
                guard let (posterUrl, index) = args, let self = self else { return Observable.never() }
                
                let _image = self.imagesProvider.rx.request(.init(posterUrl: posterUrl.posterUrl))
                    .map { response -> UIImage? in
                        return UIImage(data: response.data)
                    }.asObservable()
                
                let _index = Observable.just(index)
                
                return Observable.combineLatest(_image, _index)
        }
        
        moyaFetchImage.bind(to: _imageStream)
            .disposed(by: disposeBag)
    }
    
    private func isNewSearch(page: Int) -> Bool {
        return page == 1
    }
    
}
