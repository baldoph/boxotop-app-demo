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
    @objc dynamic var title: String?
    @objc dynamic var year: String?
    @objc dynamic var id: String?
    @objc dynamic var posterURL: String?

    override static func primaryKey() -> String? {
        return #keyPath(Movie.id)
    }

    enum CodingKeys : String, CodingKey {
        case title = "Title"
        case year = "Year"
        case id = "imdbID"
        case posterURL = "Poster"
    }
}
