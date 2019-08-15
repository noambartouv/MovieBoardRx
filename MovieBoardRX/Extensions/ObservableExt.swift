//
//  ObservablesExt.swift
//  MovieBoard
//
//  Created by Noam Bar-Touv on 08/08/2019.
//  Copyright © 2019 Noam Bar-Touv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

extension Observable {
    
    func asOptional() -> Observable<Element?> {
        return self.map { return $0 as Element? }
    }
    
    func asDriver() -> Driver<Element> {
        return self.asOptional()
            .asDriver(onErrorJustReturn: nil)
            .filterNil()
    }
}

