//
//  SearchResponse.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    var search: [Movie]

    enum CodingKeys : String, CodingKey {
        case search = "Search"
    }
}
