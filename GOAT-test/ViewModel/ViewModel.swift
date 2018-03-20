//
//  ViewModel.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

struct ForecastViewModel {
    let currentViewModel: BaseViewModel
    let hourlyViewModels: [BaseViewModel]
    let dailyViewModels: [BaseViewModel]
}

struct BaseViewModel {
    let dateTimeString: String
    let summary: String
    let temperatureString: String
}
