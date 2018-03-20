//
//  ViewController.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

class WeatherViewController: UITableViewController {
    var forecastUpdater: ForecastUpdatable? {
        didSet {
            forecastUpdater?.delegate = self
        }
    }

    private var viewModel: ForecastViewModel?
    private var isLoading = false
    private var location = Location(latitude: 0, longitude: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel == nil {
            updateForecast()
        }
    }
}

// MARK: UITableView Data Source

extension WeatherViewController {

}

// MARK: UITableView Delegate

extension WeatherViewController {

}

extension WeatherViewController: ForecastUpdatableDelegate {
    func forecastUpdater(_ updater: ForecastUpdatable, didUpdateWithForecastViewModel viewModel: ForecastViewModel) {
        OperationQueue.main.addOperation {
            self.isLoading = false
            self.viewModel = viewModel
            self.tableView.reloadData()
        }
    }

    func forecastUpdater(_ updater: ForecastUpdatable, didFailWithError error: Error) {
        OperationQueue.main.addOperation {
            self.isLoading = false
            self.presentError(error)
        }
    }
}

// MARK: Helpers

extension WeatherViewController {
    private func updateForecast() {
        guard !isLoading else { return }

        isLoading = true
        forecastUpdater?.updateForecast(forLocation: location)
    }

    private func presentError(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: "\(error)",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

