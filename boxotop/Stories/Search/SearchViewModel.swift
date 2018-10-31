//
//  SearchViewModel.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewModel: ViewModel {
    let searchInput = Variable<String?>(nil)

    override init() {
        super.init()

        searchInput.asObservable().debounce(2, scheduler: MainScheduler.instance).bind { [unowned self] value in
            guard let value = value, !value.isEmpty else { return }
            WebService.search(with: value).subscribe(onNext: { data in

                let decoder = JSONDecoder()
                do {
                    
                    let response = try decoder.decode(SearchResponse.self, from: data)
                    print(response.search)
                } catch {
                    print(error)
                }

            }, onError: { [unowned self] error in
                self.handle(error: error)
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
}
