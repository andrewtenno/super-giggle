//
//  AppDelegate.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

private let apiKey = "b9e7a3f76e0e7fbfd03680a042239e78"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if let navController = window?.rootViewController as? UINavigationController,
            let weatherViewController = navController.topViewController as? WeatherViewController {
            weatherViewController.forecastUpdater = createForecastUpdater()
        }

        return true
    }
}

private func createForecastUpdater() -> ForecastUpdatable {
    let dataFetcher = LocalDataFetcher()
    let requester = ForecastRequester(apiKey: apiKey, dataFetcher: dataFetcher)
    let generator = ForecastViewModelFactory()

    return ForecastUpdater(requester: requester, generator: generator)
}

