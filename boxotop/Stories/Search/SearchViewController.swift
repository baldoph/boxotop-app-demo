//
//  SearchViewController.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UITableViewController, Bindable {
    typealias Model = SearchViewModel

    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar()
        searchBar.placeholder = "search-bar-placeholder".localized
        navigationItem.titleView =  searchBar
    }

    func bind(viewModel: SearchViewModel) {
        searchBar.rx.text.asObservable().bind(to: viewModel.searchInput).disposed(by: disposeBag)
    }
}
