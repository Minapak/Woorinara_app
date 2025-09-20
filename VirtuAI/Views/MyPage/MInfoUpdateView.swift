import SwiftUI
import SwiftKeychainWrapper
// 서버에 업데이트 요청을 보내는 뷰
struct MInfoUpdateView: View {
    @State private var responseMessage: String?
    @State private var showErrorAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
    // 업데이트 요청을 처리하는 함수
    func updateMemberInfo(_ request: MemberUpdateRequest) {
        guard let url = URL(string: "http://43.203.237.202:18080/api/v1/members/details") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            self.errorMessage = "Failed to encode request."
            self.showErrorAlert = true
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server."
                    self.showErrorAlert = true
                }
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                do {
                    let response = try JSONDecoder().decode(MemberUpdateResponse.self, from: data)
                    DispatchQueue.main.async {
                        if response.status == 200 {
                            self.responseMessage = response.message
                        } else {
                            self.errorMessage = "Failed: \(response.message)"
                            self.showErrorAlert = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        self.showErrorAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    self.showErrorAlert = true
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Updating...")
            } else {
                Button("Update Member Info") {
                    // 버튼 클릭 시 동작할 요청을 별도로 실행합니다.
                }
                .padding()
                
                if let responseMessage = responseMessage {
                    Text("Response: \(responseMessage)")
                        .padding()
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
}

// API 응답 모델
struct MemberUpdateResponse: Codable {
    let status: Int
    let message: String
    let data: String?
}

// 업데이트 요청 모델
struct MemberUpdateRequest: Codable {
    var phoneNumber: String
    var annualIncome: Int
    var workplaceName: String
    var workplaceRegistrationNumber: String
    var workplacePhoneNumber: String
    var futureWorkplaceName: String
    var futureWorkplaceRegistrationNumber: String
    var futureWorkplacePhoneNumber: String
    var profileImageUrl: String
    var signatureUrl: String
    var koreaAddress: String
    var telephoneNumber: String
    var homelandAddress: String
    var homelandPhoneNumber: String
    var schoolStatus: String
    var schoolName: String
    var schoolPhoneNumber: String
    var schoolType: String
    var originalWorkplaceName: String
    var originalWorkplaceRegistrationNumber: String
    var originalWorkplacePhoneNumber: String
    var incomeAmount: Int
    var job: String
    var refundAccountNumber: String
}
