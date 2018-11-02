//
//  DetailsViewController.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit
import Cosmos

class DetailsViewController: UIViewController, Bindable {
    typealias Model = DetailsViewModel

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var releaseDateTitle: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var criticsRatingsTitle: UILabel!
    @IBOutlet weak var criticsRatingView: CosmosView!
    @IBOutlet weak var audienceRatingsTitle: UILabel!
    @IBOutlet weak var audienceRatingsView: CosmosView!
    @IBOutlet weak var userRatingTitle: UILabel!
    @IBOutlet weak var userRatingView: CosmosView!
    @IBOutlet weak var directorTitle: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var castTitle: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var plotTitle: UILabel!
    @IBOutlet weak var plotLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "details-controller-title".localized

        posterView.applyStyleWithRoundedCordners()
        
        audienceRatingsView.settings.updateOnTouch = false
        audienceRatingsView.settings.fillMode = .precise
        criticsRatingView.settings.updateOnTouch = false
        criticsRatingView.settings.fillMode = .precise

        userRatingView.settings.fillMode = .half
        userRatingView.set(color: Theme.secondaryColor)
        userRatingView.settings.starSize = 30
        userRatingView.didFinishTouchingCosmos = { rating in
            self.viewModel?.updateRating(with: rating)
        }

        releaseDateTitle.text = "details-release-date-title".localized
        criticsRatingsTitle.text = "details-critics-ratings-title".localized
        audienceRatingsTitle.text = "details-audience-ratings-title".localized
        userRatingTitle.text = "details-user-rating-title".localized
        directorTitle.text = "details-director-title".localized
        castTitle.text = "details-cast-title".localized
        plotTitle.text = "details-plot-title".localized
    }

    func bind(viewModel: DetailsViewModel) {
        viewModel.title.asObservable().bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.releaseDate.asObservable().bind(to: releaseDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.director.asObservable().bind(to: directorLabel.rx.text).disposed(by: disposeBag)
        viewModel.cast.asObservable().bind(to: castLabel.rx.text).disposed(by: disposeBag)
        viewModel.plot.asObservable().bind(to: plotLabel.rx.text).disposed(by: disposeBag)
        viewModel.image.asObservable().map { $0 ?? UIImage(named: "default-poster-image") }.bind(to: posterView.rx.image).disposed(by: disposeBag)

        viewModel.audienceRating.asObservable().subscribe(onNext: { value in
            if let value = value {
                self.audienceRatingsView.rating = value
                self.audienceRatingsView.set(color: Theme.secondaryColor)
                self.audienceRatingsView.text = nil
            } else {
                self.audienceRatingsView.rating = 0
                self.audienceRatingsView.set(color: .lightGray)
                self.audienceRatingsView.text = "not-applicable-label".localized
            }
        }).disposed(by: disposeBag)

        viewModel.criticsRating.asObservable().subscribe(onNext: { value in
            if let value = value {
                self.criticsRatingView.rating = value
                self.criticsRatingView.set(color: Theme.secondaryColor)
                self.criticsRatingView.text = nil
            } else {
                self.criticsRatingView.rating = 0
                self.criticsRatingView.set(color: .lightGray)
                self.criticsRatingView.text = "not-applicable-label".localized
            }
        }).disposed(by: disposeBag)

        viewModel.userRating.asObservable().subscribe(onNext: { value in
            if let value = value {
                self.userRatingView.rating = value
                self.userRatingView.set(color: Theme.secondaryColor)
            } else {
                self.userRatingView.rating = 0
                self.userRatingView.set(color: .lightGray)
            }
        }).disposed(by: disposeBag)
    }
}
