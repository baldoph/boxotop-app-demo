//
//  PosterService.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SwiftHTTP

class PosterService: Singleton {

    required init() {}

    private var cache = NSCache<NSString, UIImage>()

    private var posterDirectory: URL = {
        var cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
        var posterDirectory = cacheDirectory.appendingPathComponent("posters")
        try? FileManager.default.createDirectory(at: posterDirectory, withIntermediateDirectories: true, attributes: nil)
        return posterDirectory
    }()

    func getPoster(for movie: Movie) -> Observable<UIImage?> {
        let imageKey = movie.id as NSString

        return Observable<UIImage?>.create({ observer -> Disposable in
            // Check if in cache return an image synchronously
            if let cached = self.cache.object(forKey: imageKey) {
                observer.onNext(cached)
                return Disposables.create()
            }

            // Check if on disk and return an image synchronously
            let imageURL = self.posterDirectory.appendingPathComponent(movie.id)
            if let onDisk = UIImage(contentsOfFile: imageURL.path) {
                self.cache.setObject(onDisk, forKey: imageKey)
                observer.onNext(onDisk)
                return Disposables.create()
            }

            // Download image
            if let resourceURL = movie.posterURL {
                
                let http = HTTP.New(resourceURL, method: .GET)
                http?.run { response in
                    if let err = response.error {
                        observer.onError(err)
                    } else if let image = UIImage(data: response.data) {
                        try? response.data.write(to: imageURL)
                        self.cache.setObject(image, forKey: imageKey)
                        observer.onNext(image)
                    }
                }
                return Disposables.create {
                    http?.cancel()
                }
            }

            return Disposables.create()
        })
    }


}
