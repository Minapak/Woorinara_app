import SwiftUI
import VComponents
import VCore

struct TemporaryLinkView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            NavigationLink("여권 / 외국인 등록증 프로세스", destination: ScanView())
                            NavigationLink("통합 신청서 좌표 뷰", destination: PDFOverlayView())
                            NavigationLink("사인 이미지 저장 및 업로드", destination: ContentSignView())
                            NavigationLink("AF done", destination: AFDoneView())
//                            passportInfoLink()
//                            afCenterViewLink()
                            
                            NavigationLink("셋팅", destination: SettingsView())
                        }
                        .navigationTitle("My Page")
                    }
                    Spacer()
                }
                .padding(.bottom, 5)
                .padding(16)
            }
        }
    }

    // 여권 정보 데이터를 예시로 전달하여 NavigationLink 생성
    private func passportInfoLink() -> some View {
        let sampleResult = OCRPassResult(
            status: 200,
            message: "Success",
            data: OCRPassData(
                dateOfExpiry: "20300101",
                inferResult: "Detected",
                surName: "Kim",
                nationality: "Korea",
                gender: "M",
                documentNumber: "12345678",
                givenName: "Eunmin",
                issueCountry: "Korea",
                middleName: nil,
                dateOfBirth: "19900101",
                message: nil,
                userId: nil
            )
        )
        
        return NavigationLink("정보 텍스트 뷰 전달", destination: ScanPassView(result: sampleResult))
    }
    
    // 통합 신청서 데이터와 함께 AFCenterView로 이동하는 NavigationLink
    private func afCenterViewLink() -> some View {
        let sampleResult = OCRPassResult(
            status: 200,
            message: "Success",
            data: OCRPassData(
                dateOfExpiry: "20300101",
                inferResult: "Detected",
                surName: "Kim",
                nationality: "Korea",
                gender: "M",
                documentNumber: "12345678",
                givenName: "Eunmin",
                issueCountry: "Korea",
                middleName: nil,
                dateOfBirth: "19900101",
                message: nil,
                userId: nil
            )
        )
        
        let passportData: [String: String] = [
            "surName": sampleResult.data?.surName ?? "",
            "givenName": sampleResult.data?.givenName ?? "",
            "middleName": sampleResult.data?.middleName ?? "",
            "dateOfBirth": sampleResult.data?.dateOfBirth ?? "",
            "gender": sampleResult.data?.gender ?? "",
            "countryRegion": sampleResult.data?.issueCountry ?? "",
            "passportNumber": sampleResult.data?.documentNumber ?? "",
            "passportExpirationDate": sampleResult.data?.dateOfExpiry ?? "",
            "nationality": sampleResult.data?.nationality ?? ""
        ]
        
        return NavigationLink("통합신청서 그리기", destination: AFCenterView(passportData: passportData))
    }
}
