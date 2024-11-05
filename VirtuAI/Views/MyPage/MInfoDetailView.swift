//
//  MInfoDetailView.swift
//  Example
//
//  Created by 박은민 on 10/30/24.
//
import SwiftUI
import Foundation
import SwiftKeychainWrapper
import SafariServices
import CoreLocation

// GET 요청 응답 구조
struct InfoGetResponse: Codable {
    let status: Int
    let message: String
    let data: [MemberDetail]
}

struct MemberDetail: Codable {
    var phoneNumber: String?
    var annualIncome: String?
    var workplaceName: String?
    var workplaceRegistrationNumber: String?
    var workplacePhoneNumber: String?
    var futureWorkplaceName: String?
    var futureWorkplaceRegistrationNumber: String?
    var futureWorkplacePhoneNumber: String?
    var profileImageUrl: String?
    var signatureUrl: String?
    var koreaAddress: String?
    var telephoneNumber: String?
    var homelandAddress: String?
    var homelandPhoneNumber: String?
    var schoolStatus: String?
    var schoolName: String?
    var schoolPhoneNumber: String?
    var schoolType: String?
    var originalWorkplaceName: String?
    var originalWorkplaceRegistrationNumber: String?
    var originalWorkplacePhoneNumber: String?
    var incomeAmount: String?
    var job: String?
    var refundAccountNumber: String?
}

struct MInfoDetailView: View {
    @State private var memberDetail: MemberDetail?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let memberDetail = memberDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Member Details").font(.headline)
                        Text("Phone Number: \(memberDetail.phoneNumber ?? "N/A")")
                        Text("Annual Income: \(memberDetail.annualIncome ?? "N/A")")
                        Text("Workplace Name: \(memberDetail.workplaceName ?? "N/A")")
                        Text("Workplace Registration Number: \(memberDetail.workplaceRegistrationNumber ?? "N/A")")
                        Text("Workplace Phone Number: \(memberDetail.workplacePhoneNumber ?? "N/A")")
                        Text("Future Workplace Name: \(memberDetail.futureWorkplaceName ?? "N/A")")
                        Text("Future Workplace Registration Number: \(memberDetail.futureWorkplaceRegistrationNumber ?? "N/A")")
                        Text("Future Workplace Phone Number: \(memberDetail.futureWorkplacePhoneNumber ?? "N/A")")
                        Text("Profile Image URL: \(memberDetail.profileImageUrl ?? "N/A")")
                        Text("Signature URL: \(memberDetail.signatureUrl ?? "N/A")")
                        Text("Korea Address: \(memberDetail.koreaAddress ?? "N/A")")
                        Text("Telephone Number: \(memberDetail.telephoneNumber ?? "N/A")")
                        Text("Homeland Address: \(memberDetail.homelandAddress ?? "N/A")")
                        Text("Homeland Phone Number: \(memberDetail.homelandPhoneNumber ?? "N/A")")
                        Text("School Status: \(memberDetail.schoolStatus ?? "N/A")")
                        Text("School Name: \(memberDetail.schoolName ?? "N/A")")
                        Text("School Phone Number: \(memberDetail.schoolPhoneNumber ?? "N/A")")
                        Text("School Type: \(memberDetail.schoolType ?? "N/A")")
                        Text("Original Workplace Name: \(memberDetail.originalWorkplaceName ?? "N/A")")
                        Text("Original Workplace Registration Number: \(memberDetail.originalWorkplaceRegistrationNumber ?? "N/A")")
                        Text("Original Workplace Phone Number: \(memberDetail.originalWorkplacePhoneNumber ?? "N/A")")
                        Text("Income Amount: \(memberDetail.incomeAmount ?? "N/A")")
                        Text("Job: \(memberDetail.job ?? "N/A")")
                        Text("Refund Account Number: \(memberDetail.refundAccountNumber ?? "N/A")")
                    }
                    .padding()
                }
            } else {
                Text("No data available.")
            }
        }
        .onAppear(perform: fetchMemberDetails)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
    
    func fetchMemberDetails() {
        guard let url = URL(string: "http://43.203.237.202:18080/api/v1/members/details") else { return }
        
        lazy var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
        
        @AppStorage("username") var username: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")// AccessToken을 여기에 입력하세요

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showErrorAlert = true
                    print("Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid response from server."
                    showErrorAlert = true
                    print("Invalid response from server.")
                }
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                do {
                    let response = try JSONDecoder().decode(MemberDetailResponse.self, from: data)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.memberDetail = response.data
                            print("Fetch success: \(response.message)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Failed: \(response.message)"
                            showErrorAlert = true
                            print("Failed: \(response.message)")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Decoding error: \(error.localizedDescription)"
                        showErrorAlert = true
                        print("Decoding error: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Server error: \(httpResponse.statusCode)"
                    showErrorAlert = true
                    print("Server error: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

// 서버 응답 구조체
struct MemberDetailResponse: Codable {
    let status: Int
    let message: String
    let data: MemberDetail?
}

struct MInfoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MInfoDetailView()
    }
}
