//
//  Movie.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RealmSwift

class Movie: Object, Codable {
    @objc dynamic var title: String = ""
    @objc dynamic var year: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var posterURL: String?
    @objc dynamic var releaseDate: Date?
    @objc dynamic var userRating: String?
    @objc dynamic var audienceRating: String?
    @objc dynamic var criticsRating: String?
    @objc dynamic var director: String?
    @objc dynamic var cast: String?
    @objc dynamic var plot: String?
    @objc dynamic var visitedDate: Date?

    override static func primaryKey() -> String? {
        return #keyPath(Movie.id)
    }

    enum CodingKeys : String, CodingKey {
        case title = "Title"
        case year = "Year"
        case id = "imdbID"
        case posterURL = "Poster"
        case releaseDate = "Released"
        case audienceRating = "imdbRating"
        case criticsRating = "Metascore"
        case director = "Director"
        case cast = "Actors"
        case plot = "Plot"
    }

    var isComplete: Bool {
        return releaseDate != nil
    }
}
