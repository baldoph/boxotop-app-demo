//
//  UIImageView+Extensions.swift
//  boxotop
//
//  Created by Baldoph on 02/11/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit

extension UIImageView {
    func applyStyleWithRoundedCordners() {
        layer.cornerRadius = 4
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor.lightGray.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
