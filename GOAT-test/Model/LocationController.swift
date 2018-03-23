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
    case success(Location, String)
    case failure(Error)
}

protocol LocationFindable {
    func getLocation(completion: @escaping (LocationFindResult) -> Void)
}

class LocationController: NSObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var getLocationCompletion: ((LocationFindResult) -> Void)?

    enum LocationControllerError: Error {
        case deniedPermission
        case noLocations
        case unableToFindCityName
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
            getLocationCompletion = completion
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        } else {
            completion(.failure(LocationControllerError.deniedPermission))
        }
    }
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let foundLocation = locations.first {
            geocoder.reverseGeocodeLocation(foundLocation, completionHandler: { [weak self] (placemarks, error) in
                guard let sSelf = self else { return }

                switch (placemarks, error) {
                case (let placemarks?, _) where !placemarks.isEmpty:
                    let location = Location(latitude: foundLocation.coordinate.latitude,
                                            longitude: foundLocation.coordinate.longitude)
                    let cityName = placemarks.first?.locality ?? ""
                    sSelf.getLocationCompletion?(.success(location, cityName))
                default:
                    sSelf.getLocationCompletion?(.failure(LocationControllerError.unableToFindCityName))

                }
                sSelf.getLocationCompletion = nil
            })
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
