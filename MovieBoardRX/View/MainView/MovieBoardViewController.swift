//
//  MovieBoardViewController.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 11/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

private enum Constants {
    static let searchSegue = "SearchSegue"
}

class MovieBoardViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: MovieBoardVM = MovieBoardVM()
    private var dataSource: MovieBoardDataSource? = nil
    
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MovieBoardDataSource(viewModel: viewModel)
        setupBindings()
        
        // fetch most popular movies on startup
        viewModel.newSearchRequest.onNext(MovieDB.mostPopular(page: 1))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.searchSegue,
            let searchScreen = segue.destination as? SearchViewController else { return }
        searchScreen.viewModel = viewModel
    }
    
}

private extension MovieBoardViewController {
    
    func setupBindings() {
        guard let safeDataSource = dataSource else { return }
    
        viewModel.items
            .drive(collectionView
                .rx
                .items(dataSource: safeDataSource))
            .disposed(by: disposebag)
        
        collectionView
            .rx
            .setDelegate(safeDataSource)
            .disposed(by: disposebag)
        
        viewModel.newImage // should this be in the Datasource? Or can it be replaced/moved?
            .drive(onNext: { (image, index) in
            })
            .disposed(by: disposebag)
    }
    
}
