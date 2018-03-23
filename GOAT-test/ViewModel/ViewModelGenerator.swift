//
//  ViewModelGenerator.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

protocol ForecastViewModelGeneratable {
    func generateViewModels(fromForecast forecast: Forecast) -> ForecastViewModel
}

class ForecastViewModelFactory {
    private let currentDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter
    }()

    private let hourlyyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        return dateFormatter
    }()

    private let dailyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        return dateFormatter
    }()

    private let temperatureFormatter: MeasurementFormatter = {
        let temperatureFormatter = MeasurementFormatter()
        temperatureFormatter.unitStyle = .short

        return temperatureFormatter
    }()
}

extension ForecastViewModelFactory: ForecastViewModelGeneratable {
    func generateViewModels(fromForecast forecast: Forecast) -> ForecastViewModel {
        return ForecastViewModel(currentViewModel: generateCurrentViewModel(fromCurrentDataPoint: forecast.currently, timeZone: forecast.timeZone),
                                 hourlyViewModels: generateHourlyViewModels(fromHourlyDataBlock: forecast.hourly, timeZone: forecast.timeZone),
                                 dailyViewModels: generateDailyViewModels(fromDailyDataBlock: forecast.daily, timeZone: forecast.timeZone))
    }

    private func generateCurrentViewModel(fromCurrentDataPoint dataPoint: DataPoint, timeZone: String) -> BaseViewModel {
        currentDateFormatter.timeZone = TimeZone(identifier: timeZone)
        let dateTimeString = currentDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dataPoint.time)))
        let summary = dataPoint.summary ?? ""
        let icon = dataPoint.icon ?? ""
        let temperatureString: String
        if let temperature = dataPoint.temperature {
            temperatureString = temperatureFormatter.string(from: Measurement<UnitTemperature>.init(value: temperature, unit: .fahrenheit))
        } else {
            temperatureString = ""
        }
        let iconEmoji = convertIconToEmoji(icon)

        return BaseViewModel(dateTimeString: dateTimeString,
                                summary: summary,
                                temperatureString: iconEmoji + temperatureString)
    }

    private func generateHourlyViewModels(fromHourlyDataBlock dataBlock: DataBlock, timeZone: String) -> [BaseViewModel] {
        currentDateFormatter.timeZone = TimeZone(identifier: timeZone)
        return dataBlock.data.map({ (dataPoint) -> BaseViewModel in
            let dateTimeString = hourlyyDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dataPoint.time)))
            let summary = dataPoint.summary ?? ""
            let icon = dataPoint.icon ?? ""
            let temperatureString: String
            if let temperature = dataPoint.temperature {
                temperatureString = temperatureFormatter.string(from: Measurement<UnitTemperature>.init(value: temperature, unit: .fahrenheit))
            } else {
                temperatureString = ""
            }
            let iconEmoji = convertIconToEmoji(icon)

            return BaseViewModel(dateTimeString: dateTimeString,
                                 summary: summary,
                                 temperatureString: iconEmoji + temperatureString)
        })
    }

    private func generateDailyViewModels(fromDailyDataBlock dataBlock: DataBlock, timeZone: String) -> [BaseViewModel] {
        return dataBlock.data.map({ (dataPoint) -> BaseViewModel in
            let dateTimeString = dailyDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dataPoint.time)))
            let summary = dataPoint.summary ?? ""
            let icon = dataPoint.icon ?? ""
            let highTemperatureString: String
            if let temperature = dataPoint.temperatureHigh {
                highTemperatureString = temperatureFormatter.string(from: Measurement<UnitTemperature>.init(value: temperature, unit: .fahrenheit))
            } else {
                highTemperatureString = ""
            }
            let lowTemperatureString: String
            if let temperature = dataPoint.temperatureLow {
                lowTemperatureString = temperatureFormatter.string(from: Measurement<UnitTemperature>.init(value: temperature, unit: .fahrenheit))
            } else {
                lowTemperatureString = ""
            }
            let iconEmoji = convertIconToEmoji(icon)
            let temperatureString = "\(iconEmoji)\(lowTemperatureString) - \(highTemperatureString)"

            return BaseViewModel(dateTimeString: dateTimeString,
                                  summary: summary,
                                  temperatureString: temperatureString)
        })
    }
}
/*
 clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night
 */
private func convertIconToEmoji(_ icon: String) -> String {
    switch icon {
    case "clear-day":
        return "☀️"
    case "clear-night":
        return "🌃 "
    case "rain":
        return "☔️ "
    case "snow":
        return "❄️ "
    case "sleet":
        return "🌧 "
    case "wind":
        return "💨 "
    case "fog":
        return "🌫 "
    case "cloudy":
        return "☁️ "
    case "partly-cloudy-day":
        return "🌤 "
    case "partly-cloudy-night":
        return "☁️🌝"
    default:
        return ""
    }
}
