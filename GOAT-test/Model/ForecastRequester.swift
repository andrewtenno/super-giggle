//
//  ForecastRequestable.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

enum ForecastRequestResult {
    case success(Forecast)
    case failure(Error)
}

struct Location {
    let latitude: Double
    let longitude: Double
}

protocol ForecastRequestable {
    func performForecastFetchRequest(forLocation location: Location, completion: @escaping (ForecastRequestResult) -> Void)
}

class ForecastRequester {
    let apiKey: String
    let dataFetcher: DataFetchable

    init(apiKey: String, dataFetcher: DataFetchable) {
        self.apiKey = apiKey
        self.dataFetcher = dataFetcher
    }

    enum ForecastRequestError: Error {
        case unableToCreateURLRequest
    }
}

// MARK: ForecastRequestable

extension ForecastRequester: ForecastRequestable {
    func performForecastFetchRequest(forLocation location: Location, completion: @escaping  (ForecastRequestResult) -> Void) {
        do {
            let urlRequest = try createURLRequest(forLocation: location, apiKey: apiKey)
            print("Fetching data for URL Request: \(urlRequest)")
            dataFetcher.fetchData(forRequest: urlRequest) { (fetchResult) in
                switch fetchResult {
                case .success(let data):
                    convert(data: data, toSearchResultWithCompletion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: Helpers

private func createURLRequest(forLocation location: Location, apiKey: String) throws -> URLRequest {
    let urlString = "https://api.darksky.net/forecast/\(apiKey)/\(location.latitude),\(location.longitude)?exclude=minutely"
    guard let url = URL(string: urlString) else {
        throw ForecastRequester.ForecastRequestError.unableToCreateURLRequest
    }

    return URLRequest(url: url)
}

private func convert(data: Data, toSearchResultWithCompletion completion: @escaping (ForecastRequestResult) -> Void) {
    do {
        let searchResult = try JSONDecoder().decode(Forecast.self, from: data)
        completion(.success(searchResult))
    } catch {
        completion(.failure(error))
    }
}

