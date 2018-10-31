//
//  Dependencies.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import SwinjectStoryboard
import Swinject

extension SwinjectStoryboard {
    @objc class func setup() {
        Container.loggingFunction = nil
        registerControllers()
    }

    private class func registerControllers() {
        defaultContainer.storyboardInitCompleted(SearchViewController.self) { (r, c) in
            c.set(viewModel: SearchViewModel())
        }

        defaultContainer.storyboardInitCompleted(DetailsViewController.self) { (r, c) in
            c.set(viewModel: DetailsViewModel())
        }
    }
}
