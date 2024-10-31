import SwiftUI
import VComponents
import VCore

struct ContentVcomView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            NavigationLink("여권 / 외국인 등록증 프로세스", destination: ScanView())
                            NavigationLink("통합 신청서 좌표 뷰", destination: PDFOverlayView())
                            NavigationLink("사인 이미지 저장 및 업로드", destination: ContentSignView())
                            
                            // 여권 정보 데이터를 예시로 전달하여 NavigationLink 생성
                            NavigationLink("정보 텍스트 뷰 전달", destination: {
                                let sampleResult = OCRPassResult(status: 200, message: "Success", data: OCRPassData(dateOfExpiry: "20300101", inferResult: "Detected", surName: "Kim", nationality: "Korea", gender: "M", documentNumber: "12345678", givenName: "Eunmin", issueCountry: "Korea", middleName: nil, dateOfBirth: "19900101", message: nil, userId: nil))
                                ScanPassView(result: sampleResult)
                            })

                            NavigationLink("셋팅", destination: SettingsView())
                        }
                        .navigationTitle("My Page")
                    }
                    Spacer()
                }.padding(.bottom, 5)
                .padding(16)
            }
        }
    }
}

// MARK: Modals Examples
struct ModalsView: View {
    @State private var showModal = false
    
    var body: some View {
        VStack {
            Button("Show Modal") {
                showModal.toggle()
            }
            .sheet(isPresented: $showModal) {
                VStack {
                    Text("Modal Content")
                    Button("Close", action: { showModal = false })
                }
            }
        }
        .padding()
        .navigationTitle("Modals")
    }
}

// MARK: VContinuousSpinner Example
struct IndicatorsView: View {
    var body: some View {
        VContinuousSpinner()
            .padding()
            .navigationTitle("VContinuousSpinner")
    }
}

struct ContentVcomView_Previews: PreviewProvider {
    static var previews: some View {
        ContentVcomView()
    }
}
