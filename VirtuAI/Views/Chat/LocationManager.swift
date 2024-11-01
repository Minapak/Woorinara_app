import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLatitude: String = ""
    @Published var userLongitude: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationAccessDenied = false // 위치 접근 거부 여부

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization() // 권한 상태 확인 및 요청
    }
    
    private func checkLocationAuthorization() {
        authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationAccessDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationAccessDenied = false
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLatitude = "\(location.coordinate.latitude)"
        userLongitude = "\(location.coordinate.longitude)"
    }
}
