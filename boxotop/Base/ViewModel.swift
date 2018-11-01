//
//  ViewModel.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import RxSwift

class ViewModel {
    let disposeBag = DisposeBag()
    let error = Variable<Error?>(nil)

    func handle(error: Error) {
        self.error.value = error
    }
}
