//
//  ViewModel.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

struct ForecastViewModel {
    let currentViewModel: CurrentViewModel
    let hourlyViewModels: [HourlyViewModel]
    let dailyViewModels: [DailyViewModel]
}

protocol BaseViewModel {
    var dateTimeString: String { get }
    var summary: String { get }
    var icon: String { get }
}

struct CurrentViewModel: BaseViewModel {
    let dateTimeString: String
    let summary: String
    let icon: String

    let temperatureString: String
}

struct HourlyViewModel: BaseViewModel {
    let dateTimeString: String
    let summary: String
    let icon: String

    let temperatureString: String
}

struct DailyViewModel: BaseViewModel {
    let dateTimeString: String
    let summary: String
    let icon: String

    let temperatureHighString: String
    let temperatureLowString: String
}
