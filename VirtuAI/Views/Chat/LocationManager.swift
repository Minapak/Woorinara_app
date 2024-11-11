//
//  LocationManager.swift
//  VirtuAI
//
//  Created by 박은민 on 11/11/24.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLatitude: Double = 0.0
    @Published var userLongitude: Double = 0.0
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermissions() {
        manager.requestWhenInUseAuthorization() // Request location permissions
    }

    func requestRealTimeLocation() {
        manager.startUpdatingLocation() // Start real-time location updates
    }

    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            print("Requesting location...")
            manager.requestLocation()
        } else {
            print("Location services are not enabled.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLatitude = location.coordinate.latitude
            userLongitude = location.coordinate.longitude
            print("Location updated - Latitude: \(userLatitude), Longitude: \(userLongitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Location permission status is not determined.")
        case .restricted, .denied:
            print("Location permission has been denied.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted.")
            requestRealTimeLocation() // Start real-time updates if authorized
        @unknown default:
            print("Unknown location permission status.")
        }
    }
}
