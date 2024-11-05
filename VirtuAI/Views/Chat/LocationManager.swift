import CoreLocation
import Combine
import SwiftUI
import CoreLocationUI
import MapKit
import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLatitude: String = ""
    @Published var userLongitude: String = ""
    public var manager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            manager.requestLocation()
        } else {
            print("Location services are not enabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location.coordinate
            userLatitude = "\(location.coordinate.latitude)"
            userLongitude = "\(location.coordinate.longitude)"
            print("현재 위치 업데이트 - 위도: \(userLatitude), 경도: \(userLongitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    }

