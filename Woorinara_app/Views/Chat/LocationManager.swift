// LocationManager.swift
import Foundation
import CoreLocation
import Combine
import CoreLocationUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLatitude: Double = 0.0
    @Published var userLongitude: Double = 0.0
    private let manager = CLLocationManager()
    @Published var location: CLLocation?  // userLocation을 location으로 변경
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 서울 기본 좌표
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermissions() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestRealTimeLocation() {
        manager.startUpdatingLocation()
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
            self.location = location  // 위치 업데이트
            userLatitude = location.coordinate.latitude
            userLongitude = location.coordinate.longitude
            print("Location updated - Latitude: \(userLatitude), Longitude: \(userLongitude)")
            
            // 지도 영역 업데이트
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Location permission status is not determined.")
        case .restricted, .denied:
            print("Location permission has been denied.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted.")
            requestRealTimeLocation()
        @unknown default:
            print("Unknown location permission status.")
        }
    }
}
