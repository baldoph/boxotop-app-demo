//
//  SearchMovieCell.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit
import RxSwift

class SearchMovieCell: UITableViewCell {
    static let identifier = "SearchMovieCell"

    private var disposeBag: DisposeBag!

    var movie: Movie? {
        didSet {
            disposeBag = DisposeBag()

            titleLabel.text = movie?.title
            yearLabel.text = movie?.year
            posterView.image = UIImage(named: "default-poster-image")

            if let movie = movie {
                PosterService.shared.getPoster(for: movie).asDriver(onErrorJustReturn: nil).drive(onNext: { image in
                    self.posterView.image = image ?? UIImage(named: "default-poster-image")
                }).disposed(by: disposeBag)
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        posterView.layer.cornerRadius = 4
        posterView.layer.borderWidth = 1 / UIScreen.main.scale
        posterView.layer.borderColor = UIColor.lightGray.cgColor
        posterView.layer.shouldRasterize = true
        posterView.layer.rasterizationScale = UIScreen.main.scale
    }
}
