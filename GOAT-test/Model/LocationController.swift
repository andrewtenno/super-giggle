//
//  LocationController.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationFindResult {
    case success(Location)
    case failure(Error)
}

protocol LocationFindable {
    func getLocation(completion: @escaping (LocationFindResult) -> Void)
}

class LocationController: NSObject {
    private let locationManager = CLLocationManager()

    private var getLocationCompletion: ((LocationFindResult) -> Void)?

    enum LocationControllerError: Error {
        case deniedPermission
        case noLocations
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationController: LocationFindable {
    func getLocation(completion: @escaping (LocationFindResult) -> Void) {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            getLocationCompletion = completion
            locationManager.requestLocation()
        } else if (CLLocationManager.authorizationStatus() == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            completion(.failure(LocationControllerError.deniedPermission))
        }
    }
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let foundLocation = locations.first {
            let location = Location(latitude: foundLocation.coordinate.latitude,
                                    longitude: foundLocation.coordinate.longitude)
            getLocationCompletion?(.success(location))
            getLocationCompletion = nil
        } else {
            getLocationCompletion?(.failure(LocationControllerError.noLocations))
            getLocationCompletion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        getLocationCompletion?(.failure(error))
        getLocationCompletion = nil
    }
}
