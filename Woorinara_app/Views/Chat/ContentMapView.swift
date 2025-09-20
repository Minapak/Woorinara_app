//
//  ContentView.swift
//  core-location
//
//  Created by Guen on 29/08/2023.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

struct ContentMapView: View {
    
    @StateObject var locationManager: LocationMapManager = .init()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
                    
//            Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
            
            LocationButton(.currentLocation) {
                locationManager.manager.requestLocation()
            }
            .frame(width: 250, height: 50)
            .symbolVariant(.fill)
            .foregroundColor(.white)
            .tint(.purple)
            .clipShape(Capsule())
            .padding()
        }
    }
}

struct ContentMapView_Previews: PreviewProvider {
    static var previews: some View {
        ContentMapView()
    }
}

// Location manager
class LocationMapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var manager = CLLocationManager()
    @Published var region: MKCoordinateRegion = .init()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization() // 위치 권한 요청
    }
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패MAP: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        // 현재 위치의 위도와 경도를 로그에 출력
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print("현재 위치 - 위도: \(latitude), 경도: \(longitude)")
        
        // 지도에 현재 위치를 중심으로 설정
        region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

