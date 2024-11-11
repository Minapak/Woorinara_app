import SwiftUI
import CoreLocationUI
import CoreLocation
struct GifView: View {
    @State private var showPermissionAlert = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            VStack {
                Text("위치 권한 요청")
                    .font(.headline)
                
                Text("이 앱은 위치 권한이 필요합니다. 위치 권한을 허용하시겠습니까?")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                LocationButton(.currentLocation) {
                    locationManager.requestLocationPermissions()
                }
                .symbolVariant(.fill)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, minHeight: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
           
        }
        
    }
}


