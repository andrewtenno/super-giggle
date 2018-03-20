//
//  AppDelegate.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

enum DataFetchResult {
    case success(Data)
    case failure(Error)
}

protocol DataFetchable {
    func fetchData(forRequest request: URLRequest, completion: @escaping (DataFetchResult) -> Void)
}

class LocalDataFetcher {
    enum FetchError: Error {
        case unableToLoadMockSearchJSON
    }
}
extension LocalDataFetcher: DataFetchable {
    func fetchData(forRequest request: URLRequest, completion: @escaping (DataFetchResult) -> Void) {
        if let url = Bundle.main.url(forResource: "Mock", withExtension: "json"),
            let data = try? Data(contentsOf: url) {
            completion(.success(data))
        } else {
            completion(.failure(FetchError.unableToLoadMockSearchJSON))
        }
    }
}

class RemoteDataFetcher {
    private let urlSession: URLSession

    enum FetchError: Error {
        case serverError(Int)
        case unknown
    }

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
}

extension RemoteDataFetcher: DataFetchable {
    func fetchData(forRequest request: URLRequest, completion: @escaping (DataFetchResult) -> Void) {
        urlSession.dataTask(with: request) { (data, response, error) in
            switch (data, response, error) {
            case let (_, _, error?):
                completion(.failure(error))
            case let (data?, response as HTTPURLResponse, _) where response.statusCode == 200:
                completion(.success(data))
            case let (_?, response as HTTPURLResponse, _):
                completion(.failure(FetchError.serverError(response.statusCode)))
            default:
                completion(.failure(FetchError.unknown))
            }
        }.resume()
    }
}

