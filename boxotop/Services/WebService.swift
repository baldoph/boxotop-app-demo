//
//  WebService.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import Foundation
import RxSwift
import SwiftHTTP

enum WebServiceError: Error {
    case parameterEscapingError
}

struct WebService {
    static func search(with name: String) -> Observable<Data> {
        return Observable<Data>.create({ observer -> Disposable in
            guard let escapedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                observer.onError(WebServiceError.parameterEscapingError)
                return Disposables.create()
            }

            let http = HTTP.New("http://www.omdbapi.com/?apikey=\(APIKey)&s=\(escapedName)", method: .GET)
            http?.run { response in
                if let err = response.error {
                    observer.onError(err)
                } else {
                    observer.onNext(response.data)
                    observer.onCompleted()
                }

                NetworkActivityIndicator.sharedInstance().hide()
            }

            NetworkActivityIndicator.sharedInstance().show()

            return Disposables.create {
                http?.cancel()
            }
        })
    }

    static func get(with id: String) -> Observable<Data> {
        return Observable<Data>.create({ observer -> Disposable in
            let http = HTTP.New("http://www.omdbapi.com/?apikey=\(APIKey)&i=\(id)", method: .GET)
            http?.run { response in
                if let err = response.error {
                    observer.onError(err)
                } else {
                    observer.onNext(response.data)
                    observer.onCompleted()
                }
                
                NetworkActivityIndicator.sharedInstance().hide()
            }

            NetworkActivityIndicator.sharedInstance().show()

            return Disposables.create {
                http?.cancel()
            }
        })
    }
}
