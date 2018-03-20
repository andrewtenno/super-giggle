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

    enum ViewingMode {
        case daily, hourly
    }
    private var viewingMode: ViewingMode = .daily

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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        switch section {
        case 0:
            return 1
        case 1 where viewingMode == .daily:
            return viewModel.dailyViewModels.count
        case 2 where viewingMode == .hourly:
            return viewModel.hourlyViewModels.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = determineReuseIdentifier(forSection: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // TODO: Add View Model binding to cell

        return cell
    }

    private func determineReuseIdentifier(forSection section: Int) -> String {
        switch section {
        case 0:
            return "currentCell"
        case 1:
            return "dailyCell"
        case 2:
            return "hourlyCell"
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard viewModel != nil else { return nil }

        switch section {
        case 0:
            return "TODAY"
        case 1 where viewingMode == .daily:
            return "DAILY"
        case 2 where viewingMode == .hourly:
            return "HOURLY"
        default:
            return nil
        }
    }
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

