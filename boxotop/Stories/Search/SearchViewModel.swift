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

    var persistedMovies: Results<Movie>? = {
        if let realm = try? Realm() {
            return realm.objects(Movie.self).sorted(byKeyPath: #keyPath(Movie.visitedDate), ascending: false)
        }
        return nil
    }()

    override init() {
        clearHistoryButtonEnabled = Observable.combineLatest(searchInput.asObservable(), isSearchBarFirstResponder.asObservable(), results.asObservable(), resultSelector: { (searchInput, isSearchBarFirstResponder, results) -> Bool in
            return (searchInput?.isEmpty ?? true) && !isSearchBarFirstResponder && !results.isEmpty
        })

        showEmptyBackground = Observable.combineLatest(isSearchBarFirstResponder.asObservable(), results.asObservable(), searchInput.asObservable(), resultSelector: { (isSearchBarFirstResponder, results, searchInput) -> Bool in
            return !isSearchBarFirstResponder && results.isEmpty && (searchInput == nil || searchInput!.isEmpty)
        })

        results.value = persistedMovies?.map { $0 } ?? []

        super.init()

        searchInput.asObservable().flatMap { value -> Observable<String> in
            if value == nil || value!.isEmpty {
                if self.isSearchBarFirstResponder.value { self.results.value = [] }
                return Observable.never()
            }
            self.showNoResultsLabel.value = false
            return Observable.from(optional: value)
        }.debounce(0.2, scheduler: MainScheduler.instance).bind { [unowned self] value in

            WebService.search(with: value).subscribe(onNext: { [unowned self] data in
                DispatchQueue.main.async {
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(SearchResponse.self, from: data)
                        if self.isSearchBarFirstResponder.value {
                            self.results.value = response.movies
                        }
                    } catch { // Error when optional "Search" key is not present in JSON (case where no movies are returned)
                        // For simplicity, we're not overriding init method of codables objects but just handling "no movies" case here
                        self.results.value = []
                        if value.count > 1 {
                            self.showNoResultsLabel.value = true
                        }
                    }
                }
            }, onError: { [unowned self] error in
                DispatchQueue.main.async {
                    self.handle(error: error)
                }
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        isSearchBarFirstResponder.asObservable().subscribe(onNext: { [unowned self] isFirst in
            if isFirst && (self.searchInput.value == nil || self.searchInput.value!.isEmpty) {
                self.results.value = []
            } else if !isFirst && (self.searchInput.value == nil || self.searchInput.value!.isEmpty) {
                self.results.value = self.persistedMovies?.map { $0 } ?? []
            }
        }).disposed(by: disposeBag)
    }

    func clearHistory() {
        guard let movies = persistedMovies, let realm = try? Realm() else { return }

        try? realm.write {
            realm.delete(movies)
        }

        results.value = []
    }
}
