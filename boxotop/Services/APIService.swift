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

enum APIServiceError: Error {
    case parameterEscapingError
}

struct APIService {
    private static let decodingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()

    static func search(with name: String) -> Observable<SearchResponse> {
        return Observable<SearchResponse>.create({ observer -> Disposable in
            guard let escapedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                observer.onError(APIServiceError.parameterEscapingError)
                return Disposables.create()
            }

            NetworkActivityIndicator.sharedInstance().show()

            let http = HTTP.New("http://www.omdbapi.com/?apikey=\(APIKey)&type=movie&s=\(escapedName)", method: .GET)
            http?.run { response in
                DispatchQueue.main.async {
                    if let err = response.error {
                        observer.onError(err)
                    } else {
                        let decoder = JSONDecoder()
                        do {
                            let searchResponse = try decoder.decode(SearchResponse.self, from: response.data)
                            observer.onNext(searchResponse)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    NetworkActivityIndicator.sharedInstance().hide()
                }
            }

            return Disposables.create {
                http?.cancel()
            }
        })
    }

    static func get(with id: String) -> Observable<Movie> {
        return Observable<Movie>.create({ observer -> Disposable in
            NetworkActivityIndicator.sharedInstance().show()

            let http = HTTP.New("http://www.omdbapi.com/?apikey=\(APIKey)&i=\(id)", method: .GET)
            http?.run { response in
                DispatchQueue.main.async {
                    if let err = response.error {
                        observer.onError(err)
                    } else {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(decodingDateFormatter)
                        do {
                            let movie = try decoder.decode(Movie.self, from: response.data)
                            observer.onNext(movie)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    NetworkActivityIndicator.sharedInstance().hide()
                }
            }

            return Disposables.create {
                http?.cancel()
            }
        })
    }
}
