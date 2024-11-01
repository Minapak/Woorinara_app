//
//  ContentMapView.swift
//  Demo-iOS
//
//  Created by 박은민 on 10/19/24.
//

import SwiftUI

struct ContentMapView: View {
    @State private var startLatitude: String = ""
    @State private var startLongitude: String = ""
    @State private var endLatitude: String = ""
    @State private var endLongitude: String = ""
    @State private var routeInfo: String = ""
    
    var body: some View {
        VStack {
            Text("출발지와 도착지 경로 찾기")
                .font(.largeTitle)
                .padding()

            // 출발지 입력
            VStack(alignment: .leading) {
                Text("출발지 위도:")
                TextField("출발지 위도 입력", text: $startLatitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                Text("출발지 경도:")
                TextField("출발지 경도 입력", text: $startLongitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
            }

            // 도착지 입력
            VStack(alignment: .leading) {
                Text("도착지 위도:")
                TextField("도착지 위도 입력", text: $endLatitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
                
                Text("도착지 경도:")
                TextField("도착지 경도 입력", text: $endLongitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)
            }

            // 경로 찾기 버튼
            Button(action: {
                fetchRoute()
            }) {
                Text("경로 찾기")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            // 결과 출력
            Text("경로 정보:")
                .font(.headline)
                .padding(.top)
            
            Text(routeInfo)
                .padding()
                .multilineTextAlignment(.leading)
                .border(Color.gray, width: 1)
                .padding()
        }
        .padding()
    }
    
    // API 호출 함수
    func fetchRoute() {
        guard let startLat = Double(startLatitude),
              let startLong = Double(startLongitude),
              let endLat = Double(endLatitude),
              let endLong = Double(endLongitude) else {
            routeInfo = "유효하지 않은 입력입니다."
            return
        }
        
        let start = "\(startLong),\(startLat)"
        let goal = "\(endLong),\(endLat)"
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-direction-5/v1/driving?start=\(start)&goal=\(goal)&option=trafast"
        
        guard let url = URL(string: urlString) else {
            routeInfo = "유효하지 않은 URL입니다."
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("YOUR_API_KEY", forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue("YOUR_SECRET_KEY", forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    routeInfo = "경로 데이터를 불러오는데 실패했습니다."
                }
                return
            }
            
            do {
                // JSON 파싱
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let routes = json?["routes"] as? [[String: Any]],
                   let summary = routes.first?["summary"] as? [String: Any],
                   let duration = summary["duration"] as? Int,
                   let distance = summary["distance"] as? Int {
                    
                    DispatchQueue.main.async {
                        routeInfo = "총 거리: \(distance)m, 예상 소요 시간: \(duration / 60)분"
                    }
                } else {
                    DispatchQueue.main.async {
                        routeInfo = "경로 정보를 찾을 수 없습니다."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    routeInfo = "JSON 데이터를 처리하는 중 오류가 발생했습니다."
                }
            }
        }.resume()
    }
}

struct ContentMapView_Previews: PreviewProvider {
    static var previews: some View {
        ContentMapView()
    }
}
