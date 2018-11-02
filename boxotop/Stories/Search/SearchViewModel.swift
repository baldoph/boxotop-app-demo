//
//  SearchViewModel.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class SearchViewModel: ViewModel {
    let searchInput = Variable<String?>(nil)
    let isSearchBarFirstResponder = Variable<Bool>(false)
    let showNoResultsLabel = Variable<Bool>(false)
    let clearHistoryButtonEnabled: Observable<Bool>
    let showEmptyBackground: Observable<Bool>

    var results = Variable<[Movie]>([])
    var sectionTitle: String?

    var persistedMovies: Results<Movie>? = {
        if let realm = try? Realm() {
            return realm.objects(Movie.self).sorted(byKeyPath: #keyPath(Movie.visitedDate), ascending: false)
        }
        return nil
    }()

    override init() {
        // create obervables
        clearHistoryButtonEnabled = Observable.combineLatest(searchInput.asObservable(), isSearchBarFirstResponder.asObservable(), results.asObservable(), resultSelector: { (searchInput, isSearchBarFirstResponder, results) -> Bool in
            return (searchInput?.isEmpty ?? true) && !isSearchBarFirstResponder && !results.isEmpty
        })

        showEmptyBackground = Observable.combineLatest(isSearchBarFirstResponder.asObservable(), results.asObservable(), searchInput.asObservable(), resultSelector: { (isSearchBarFirstResponder, results, searchInput) -> Bool in
            return !isSearchBarFirstResponder && results.isEmpty && (searchInput == nil || searchInput!.isEmpty)
        })

        super.init()

        // bind search input changes
        searchInput.asObservable().flatMap { value -> Observable<String> in
            self.showNoResultsLabel.value = false // hide label on input changes
            if value == nil || value!.isEmpty {
                if self.isSearchBarFirstResponder.value { self.results.value = [] } // clear list on empty input
                return Observable.never()
            }
            return Observable.from(optional: value)
        }.debounce(0.2, scheduler: MainScheduler.instance).bind { [unowned self] value in // add debounce to reduce web requests overhead
            APIService.search(with: value).subscribe(onNext: { [unowned self] searchResponse in // request movie list from API
                if self.isSearchBarFirstResponder.value { // still searching for movies
                    self.results.value = searchResponse.movies
                }
            }, onError: { [unowned self] error in
                switch error {
                case DecodingError.keyNotFound(SearchResponse.CodingKeys.movies, _):
                    // error when optional "Search" key is not present in JSON (case where search returns no results)
                    // for simplicity, we're not overriding init method of Codable SearchResponse objects but just handling "no movies" case here
                    self.results.value = []
                    if value.count > 1 {
                        self.showNoResultsLabel.value = true
                    }
                default:
                    self.handle(error: error)
                }
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        isSearchBarFirstResponder.asObservable().subscribe(onNext: { [unowned self] isFirst in
            if isFirst && (self.searchInput.value == nil || self.searchInput.value!.isEmpty) { // empty table view on search bar become first responder
                self.sectionTitle = nil
                self.results.value = []
            } else if !isFirst && (self.searchInput.value == nil || self.searchInput.value!.isEmpty) { // fall back to persisted movies list when search bar is cleared and resigned first responder
                let persistedMovies =  self.persistedMovies?.map { $0 } ?? []
                if persistedMovies.count > 0 {
                    self.sectionTitle = "history-section-title".localized
                }
                self.results.value = persistedMovies
            }
        }).disposed(by: disposeBag)
    }

    func clearHistory() {
        guard let movies = persistedMovies, let realm = try? Realm() else { return }
        try? realm.write {
            realm.delete(movies)
        }
        sectionTitle = nil
        results.value = []
    }
}
