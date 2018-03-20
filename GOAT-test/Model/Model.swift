//
//  Model.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation

struct Forecast: Decodable {
    let currently: DataPoint?
    let daily: DataBlock
    let hourly: DataBlock
    let timeZone: String

    enum CodingKeys: String, CodingKey {
        case currently, daily, hourly
        case timeZone = "timezone"
    }
}

struct DataBlock: Decodable {
    let data: [DataPoint]
    let summary: String?
    let icon: String?
}

struct DataPoint: Decodable {
    let time: Int
    let summary: String?
    let icon: String?
    let temperature: Double?
    let temperatureHigh: Double?
    let temperatureLow: Double?
}
