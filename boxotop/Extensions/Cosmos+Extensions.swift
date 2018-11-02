//
//  Cosmos+Extensions.swift
//  boxotop
//
//  Created by Baldoph on 01/11/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit
import Cosmos

// Cosmos is a framework to display starred ratings.

extension CosmosView {
    func set(color: UIColor) {
        settings.emptyBorderColor = color
        settings.filledBorderColor = color
        settings.filledColor = color
    }
}
