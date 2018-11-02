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
    
    @IBOutlet var tableBackground: UIView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var emptyTableHeaderTitle: UILabel!
    @IBOutlet weak var emptyTableHeaderSubtitle: UILabel!
    @IBOutlet weak var emptyTableHeader: UIView!
    @IBOutlet weak var clearHistoryButton: UIBarButtonItem!
    @IBOutlet weak var noResultsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var noResultsTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyTableHeaderTitle.text = "empty-history-header".localized
        emptyTableHeaderSubtitle.text = "empty-history-subtitle".localized
        noResultsLabel.text = "no-results-title".localized

        searchBar = UISearchBar()
        searchBar.placeholder = "search-bar-placeholder".localized
        navigationItem.titleView =  searchBar

        tableView.backgroundView = tableBackground
        tableView.tableFooterView = UIView()

        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification).subscribe(onNext: { [unowned self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                self.noResultsBottomConstraint.constant = keyboardFrame.cgRectValue.height
            }
        }).disposed(by: disposeBag)

        clearHistoryButton.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "clear-history-button-title".localized, style: .destructive, handler: { _ in
                self.viewModel.clearHistory()
            }))
            actionSheet.addAction(UIAlertAction(title: "cancel-button-action".localized, style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noResultsTopConstraint.constant = topLayoutGuide.length
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsController = segue.destination as? DetailsViewController, let movie = sender as? Movie {
            detailsController.viewModel.movie = movie
        }
    }

    // MARK: - Bindable conformance

    func bind(viewModel: SearchViewModel) {
        searchBar.rx.text.asObservable().bind(to: viewModel.searchInput).disposed(by: disposeBag)
        searchBar.rx.textDidBeginEditing.map { true }.bind(to: viewModel.isSearchBarFirstResponder).disposed(by: disposeBag)
        searchBar.rx.textDidEndEditing.map { false }.bind(to: viewModel.isSearchBarFirstResponder).disposed(by: disposeBag)

        viewModel.results.asObservable().subscribe(onNext: { [unowned self] _ in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.showEmptyBackground.asObservable().subscribe(onNext: { [unowned self] show in
            UIView.animate(withDuration: 0.3, delay: 0.02, options: .beginFromCurrentState, animations: {
                self.emptyTableHeader.alpha = show ? 1 : 0
            }, completion: nil)
        }).disposed(by: disposeBag)

        viewModel.showNoResultsLabel.asObservable().map { !$0 }.bind(to: noResultsLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.clearHistoryButtonEnabled.bind(to: clearHistoryButton.rx.isEnabled).disposed(by: disposeBag)
    }

    // MARK: - TableView protocols

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchMovieCell.identifier, for: indexPath)
        if let movieCell = cell as? SearchMovieCell {
            movieCell.movie = viewModel.results.value[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        let movie = viewModel.results.value[indexPath.row]
        performSegue(withIdentifier: ShowDetailsSegueName, sender: movie)
    }
}
