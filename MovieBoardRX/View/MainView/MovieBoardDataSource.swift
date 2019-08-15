//
//  CollectionMovieDataSource.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 08/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MovieBoardDataSource : NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource, UICollectionViewDelegate {
    typealias Element = [MovieItem]
    
    var items = Element()
    var viewModel: MovieBoardVM
    let disposeBag = DisposeBag()
    
    init(viewModel: MovieBoardVM) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.movieCell, for: indexPath) as? MovieGridCollectionViewCell else { return UICollectionViewCell() }
        let index = indexPath.row
    
        let imageSource = viewModel.items.flatMap { _items in
            return _items[safe: index]?.image ?? Driver.never()
        }

        imageSource.map { [weak self] _image in
            guard let self = self else { return }
            if  _image != nil {
                // image exists in cache
                cell.movieImage.image = _image
            } else {
                // set placeholder and fetch image from DB
                cell.movieImage.image = UIImage(named: "PlaceHolder")
                self.viewModel.moviePosterRequest.onNext(index)
            }
        }
        .drive()
        .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[MovieItem]>) {
        if case .next(let items) = observedEvent {
            self.items = items
            collectionView.reloadData()
        }
        
        // scroll back to top on new request
        viewModel.itemsPageCount.filter { _page in _page == 1 }.map { _ in
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
            .drive()
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("index path is: \(indexPath)")
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - Consts.minAmountOfAdditonalCachedMovies {
            viewModel.operationOnCurrentSearch.onNext(.increment)
        }
    }
    
}

extension MovieBoardDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let cellWidth: CGFloat = screenWidth / 2
        let cellHeight: CGFloat = cellWidth * Consts.imageAspectRation
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension MovieBoardDataSource {
    
    private enum Constants {
        static let movieCell = "MovieCell"
    }
    
}
