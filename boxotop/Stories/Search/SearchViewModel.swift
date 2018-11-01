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
    let isSearchBarFirstResponder = Variable<Bool>(false)
    let showEmptyBackground = Variable<Bool>(false)
    let showNoResultsLabel = Variable<Bool>(false)
    let clearHistoryButtonEnabled: Observable<Bool>

    var results = Variable<[Movie]>([])

    override init() {
        clearHistoryButtonEnabled = Observable.zip(searchInput.asObservable(), isSearchBarFirstResponder.asObservable(), results.asObservable(), resultSelector: { (searchInput, isSearchBarFirstResponder, results) -> Bool in
            return (searchInput?.isEmpty ?? true) && !isSearchBarFirstResponder && !results.isEmpty
        })

        super.init()

        searchInput.asObservable().flatMap { value -> Observable<String> in
            if value == nil || value!.isEmpty {
                self.results.value = []
            }
            self.showNoResultsLabel.value = false
            return Observable.from(optional: value)
        }.debounce(0.2, scheduler: MainScheduler.instance).bind { [unowned self] value in
            
            WebService.search(with: value).subscribe(onNext: { [unowned self] data in
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(SearchResponse.self, from: data)
                    if self.isSearchBarFirstResponder.value {
                        self.results.value = response.movies
                    }
                } catch { // Error on optional Search Key not present when no movies are returned.
                    // For simplicity, we're not overriding init method of codables objects but just handling "no movies" case here
                    self.results.value = []
                    if value.count > 1 {
                        self.showNoResultsLabel.value = true
                    }
                }
            }, onError: { [unowned self] error in
                self.handle(error: error)
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        isSearchBarFirstResponder.asObservable().subscribe(onNext: { [unowned self] isFirst in
            self.showEmptyBackground.value = !isFirst && self.results.value.isEmpty
        }).disposed(by: disposeBag)
    }
}
