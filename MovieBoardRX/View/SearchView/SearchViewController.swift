//
//  SearchViewController.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 15/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    enum Constants {
        static let searchOptioncell = "SearchOptionCell"
        static let mostPoplular  = "Most Popular"
        static let mostRecent = "Most Recent Releases"
        static let topRated = "Top Rated"
    }
    
    weak var viewModel: MovieBoardVM? = nil
    
    let searchOptions: [SearchOption] =
        [SearchOption(textToDisplay: Constants.mostPoplular, urlString: Consts.searchMoviesByDiscover),
         SearchOption(textToDisplay: Constants.mostRecent, urlString: Consts.searchMoviesByDiscover),
         SearchOption(textToDisplay: Constants.topRated, urlString: Consts.searchMoviesByDiscover)]
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        viewModel?.newSearchRequest.onNext(MovieDB.freeSearch(query: query, page: 1))
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SearchOptionViewCell
        let label = cell?.searchLabel.text
        
        switch label {
        case Constants.mostPoplular:
            viewModel?.newSearchRequest.onNext(MovieDB.mostPopular(page: 1))
        case Constants.mostRecent:
            viewModel?.newSearchRequest.onNext(MovieDB.mostRecent(page: 1))
        case Constants.topRated:
            viewModel?.newSearchRequest.onNext(MovieDB.topRated(page: 1))
        default:
            viewModel?.newSearchRequest.onNext(MovieDB.mostPopular(page: 1))
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.searchOptioncell, for: indexPath) as! SearchOptionViewCell
        cell.searchLabel.text = searchOptions[indexPath.row].textToDisplay
        return cell
    }
}
