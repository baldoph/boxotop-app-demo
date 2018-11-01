//
//  DetailsViewModel.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RealmSwift

class DetailsViewModel: ViewModel {
    var title = Variable<String?>(nil)
    var releaseDate = Variable<String?>(nil)
    var director = Variable<String?>(nil)
    var image = Variable<UIImage?>(nil)
    var cast = Variable<String>("")
    var plot = Variable<String>("")
    var userRating = Variable<Double?>(nil)
    var criticsRating = Variable<Double?>(nil)
    var audienceRating = Variable<Double?>(nil)

    private static let decodingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.decimalSeparator = "."
        return formatter
    }()

    var movie: Movie? {
        didSet {
            // fetch complete info if necessary
            if let movie = movie, !movie.isComplete {
                WebService.get(with: movie.id).subscribe(onNext: { [unowned self] data in
                    DispatchQueue.main.async {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(DetailsViewModel.decodingDateFormatter)
                        do {
                            self.movie = try decoder.decode(Movie.self, from: data)
                        } catch {
                            print(error)
                        }
                    }
                }, onError: { [unowned self] error in
                    DispatchQueue.main.async {
                        self.handle(error: error)
                    }
                }).disposed(by: self.disposeBag)
            } else if let movie = movie, movie.isComplete, movie.realm == nil, let realm = try? Realm() {
                // Add visited movie to realm for persistency
                movie.visitedDate = Date()
                try? realm.write {
                    realm.add(movie)
                }
            }

            title.value = movie?.title ?? "not-applicable-label".localized
            cast.value = movie?.cast ?? "not-applicable-label".localized
            director.value = movie?.director ?? "not-applicable-label".localized
            plot.value = movie?.plot ?? "not-applicable-label".localized

            if let date = movie?.releaseDate {
                releaseDate.value = DetailsViewModel.displayDateFormatter.string(from: date)
            } else {
                releaseDate.value = "not-applicable-label".localized
            }

            if let rating = movie?.criticsRating, let doubleValue = Double(rating) {
                criticsRating.value = doubleValue * 5 / 100
            } else {
                criticsRating.value = nil
            }

            if let rating = movie?.audienceRating, let doubleValue = DetailsViewModel.decimalFormatter.number(from: rating)?.doubleValue {
                audienceRating.value = doubleValue / 2
            } else {
                audienceRating.value = nil
            }

            if let rating = movie?.userRating, let doubleValue = Double(rating) {
                userRating.value = doubleValue
            } else {
                userRating.value = nil
            }

            if let movie = movie {
                PosterService.shared.getPoster(for: movie).asDriver(onErrorJustReturn: nil).drive(onNext: { [unowned self] image in
                    self.image.value = image
                }).disposed(by: disposeBag)
            }
        }
    }

    func updateRating(with value: Double) {
        guard let realm = try? Realm(), let movie = movie else { return }
        try? realm.write {
            movie.userRating = String(value)
        }
        userRating.value = value
    }
}
