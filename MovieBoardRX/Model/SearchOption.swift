//
//  SearchOption.swift
//  MovieBoardRX
//
//  Created by Noam Bar-Touv on 15/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation

public struct SearchOption {
    let textToDisplay: String
    let urlString: String
    
    init(textToDisplay: String, urlString: String) {
        self.textToDisplay = textToDisplay
        self.urlString = urlString
    }
}
