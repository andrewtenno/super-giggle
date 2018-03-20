//
//  ForecastUpdater.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

protocol ForecastUpdatable {
    weak var delegate: ForecastUpdatableDelegate? { get set }
    func updateForecast(forLocation location: Location)
}

protocol ForecastUpdatableDelegate: class {
    func forecastUpdater(_ updater: ForecastUpdatable, didUpdateWithForecastViewModel viewModel: ForecastViewModel)
    func forecastUpdater(_ updater: ForecastUpdatable, didFailWithError error: Error)
}

class ForecastUpdater: ForecastUpdatable {
    weak var delegate: ForecastUpdatableDelegate?
    private let requester: ForecastRequestable
    private let generator: ForecastViewModelGeneratable
    private let updateQueue = DispatchQueue(label: "com.GOAT-test.forecast-updater", qos: .userInitiated)

    init(requester: ForecastRequestable, generator: ForecastViewModelGeneratable) {
        self.requester = requester
        self.generator = generator
    }

    func updateForecast(forLocation location: Location) {
        updateQueue.async { [weak self] in
            self?.requester.performForecastFetchRequest(forLocation: location, completion: { (result) in
                self?.updateQueue.async {
                    self?.handleForecastRequestResponse(response: result)
                }
            })
        }
    }

    private func handleForecastRequestResponse(response: ForecastRequestResult) {
        switch response {
        case .success(let forecast):
            let viewModel = generator.generateViewModels(fromForecast: forecast)
            delegate?.forecastUpdater(self, didUpdateWithForecastViewModel: viewModel)
        case .failure(let error):
            delegate?.forecastUpdater(self, didFailWithError: error)
        }
    }
}
