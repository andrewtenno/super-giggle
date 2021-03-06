//
//  ViewController.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UITableViewController {
    var forecastUpdater: ForecastUpdatable? {
        didSet {
            forecastUpdater?.delegate = self
        }
    }
    var locationController: LocationFindable?

    private var viewModel: ForecastViewModel?
    private var isLoading = false
    private var locationString = "Los Angeles"
    private var location = Location(latitude: 37.8267,
                                    longitude: -122.4233)

    @IBOutlet weak var changeRangeButton: UIButton!
    @IBOutlet weak var changeLocationButton: UIBarButtonItem!

    enum ViewingMode {
        case daily, hourly
    }
    private var viewingMode: ViewingMode = .daily

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel == nil && !isLoading {
            updateForecast()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentSummaryViewController",
            let summaryViewController = segue.destination as? ModalSummaryViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let viewModel = getViewModel(forIndexPath: selectedIndexPath) {
            summaryViewController.viewModel = viewModel
            summaryViewController.modalPresentationStyle = .custom
            summaryViewController.transitioningDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    @IBAction func didTapChangeRangeButton(_ sender: Any) {
        presentSwitchRangeActionSheet()
    }
    @IBAction func didTapChangeLocationButton(_ sender: Any) {
        attemptToFindLocation()
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
        guard let viewModel = getViewModel(forIndexPath: indexPath) else { fatalError() }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)

        if let currentCell = cell as? ForecastCell {
            currentCell.viewModel = viewModel
        }

        return cell
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "presentSummaryViewController", sender: nil)
    }
}

// MARK: ForecastUpdatableDelegate

extension WeatherViewController: ForecastUpdatableDelegate {
    func forecastUpdater(_ updater: ForecastUpdatable, didUpdateWithForecastViewModel viewModel: ForecastViewModel) {
        OperationQueue.main.addOperation {
            self.title = self.locationString
            self.isLoading = false
            self.changeRangeButton.isEnabled = true
            self.changeLocationButton.isEnabled = true
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

// MARK: Switch Daily/Hourly 

extension WeatherViewController {
    private func presentSwitchRangeActionSheet() {
        let sortingString = "Currently showing \(viewingMode == .daily ? "Daily" : "Hourly") Forecast"
        let alertController = UIAlertController(title: "Switch Range?", message: sortingString, preferredStyle: .actionSheet)
        let title = "Switch to \(viewingMode == .hourly ? "Daily" : "Hourly")"
        alertController.addAction(UIAlertAction(title: title, style: .default) { [weak self] (_) in
            self?.flipSortingMethod()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    private func flipSortingMethod() {
        OperationQueue.main.addOperation {
            self.viewingMode = self.viewingMode == .daily ? .hourly : .daily
            self.tableView.reloadData()
        }
    }
}

// MARK: - Custom Modal Animation

extension WeatherViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresenterAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalAnimator()
    }
}

// MARK: Helpers

extension WeatherViewController {
    private func updateForecast() {
        isLoading = true
        changeRangeButton.isEnabled = false
        changeLocationButton.isEnabled = false
        forecastUpdater?.updateForecast(forLocation: location)
    }

    private func presentError(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: "\(error)",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    private func getViewModel(forIndexPath indexPath: IndexPath) -> BaseViewModel? {
        guard let viewModel = viewModel else { return nil }

        switch indexPath.section {
        case 0:
            return viewModel.currentViewModel
        case 1 where viewingMode == .daily:
            return viewModel.dailyViewModels[indexPath.row]
        case 2 where viewingMode == .hourly:
            return viewModel.hourlyViewModels[indexPath.row]
        default:
            return nil
        }
    }

    private func attemptToFindLocation() {
        self.isLoading = true
        self.changeRangeButton.isEnabled = false
        self.changeLocationButton.isEnabled = false
        locationController?.getLocation(completion: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .success(let (location, cityName)):
                OperationQueue.main.addOperation {
                    sSelf.location = location
                    sSelf.locationString = cityName
                    sSelf.updateForecast()
                }
            case .failure(let error):
                OperationQueue.main.addOperation {
                    sSelf.isLoading = false
                    sSelf.changeRangeButton.isEnabled = true
                    sSelf.changeLocationButton.isEnabled = true
                    sSelf.presentError(error)
                }
            }
        })
    }
}
