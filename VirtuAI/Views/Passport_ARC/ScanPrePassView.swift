
import SwiftUI
import AVFoundation
import SwiftKeychainWrapper

// MARK: - 카메라 캡처 컴포넌트
/// SwiftUI에서 카메라 기능을 사용하기 위한 UIImagePickerController 래퍼
struct CameraCapturePassView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?    // 촬영된 이미지를 저장할 바인딩
    @Binding var isPresented: Bool          // 카메라 뷰 표시 여부 제어
    
    // UIImagePickerController 생성 및 설정
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 카메라 작업을 처리하는 코디네이터 클래스
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCapturePassView
        
        init(_ parent: CameraCapturePassView) {
            self.parent = parent
        }
        
        // 이미지 촬영 완료 시 처리
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            parent.isPresented = false
        }
        
        // 촬영 취소 시 처리
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - 데이터 모델
/// 네이버 OCR API 응답 모델
struct PassportNaverResponse: Codable {
    let status: Int          // 응답 상태 코드
    let message: String      // 응답 메시지
    let data: PassportNaverData?  // OCR 결과 데이터
}

/// OCR API로부터 받는 여권 데이터 모델
struct PassportNaverData: Codable {
    let dateOfExpiry: String?    // 만료일
    let inferResult: String?     // 인식 결과
    let surName: String?         // 성
    let nationality: String?     // 국적
    let gender: String?          // 성별
    let documentNumber: String?  // 여권번호
    let givenName: String?       // 이름
    let issueCountry: String?    // 발급국가
    let middleName: String?      // 중간이름
    let dateOfBirth: String?     // 생년월일
    let message: String?         // 처리 메시지
    let userId: String?           // 사용자 ID
    // JSON 매핑을 위한 코딩키
    enum CodingKeys: String, CodingKey {
        case dateOfExpiry
        case inferResult
        case surName
        case nationality
        case gender
        case documentNumber
        case givenName
        case issueCountry
        case middleName
        case dateOfBirth
        case message
        case userId
    }
}

// MARK: - 모델 확장
extension PassportNaverResponse {
    /// API 응답을 앱 내부 모델로 변환
    func toPassportResult() -> PassportResult {
        return PassportResult(
            status: self.status,
            message: self.message,
            data: PassportData(
                documentNumber: self.data?.documentNumber,
                surName: self.data?.surName,
                givenName: self.data?.givenName,
                nationality: self.data?.nationality,
                dateOfBirth: self.data?.dateOfBirth,
                gender: self.data?.gender,
                dateOfExpiry: self.data?.dateOfExpiry,
                dateOfIssue: nil,  // API 응답에 없는 필드
                issueCountry: self.data?.issueCountry
            )
        )
    }
}

/// 앱 내부에서 사용할 여권 결과 모델
struct PassportResult: Codable {
    var status: Int
    var message: String
    var data: PassportData?
}

/// 앱 내부에서 사용할 여권 데이터 모델
struct PassportData: Codable {
    var documentNumber: String?
    var surName: String?
    var givenName: String?
    var nationality: String?
    var dateOfBirth: String?
    var gender: String?
    var dateOfExpiry: String?
    var dateOfIssue: String?
    var issueCountry: String?
    // JSON 매핑을 위한 코딩키
    enum CodingKeys: String, CodingKey {
        case documentNumber
        case surName
        case givenName
        case nationality
        case dateOfBirth
        case gender
        case dateOfExpiry
        case dateOfIssue
        case issueCountry
    }

    
    
    
}

// MARK: - 메인 뷰
struct ScanPrePassView: View {
    // MARK: - 속성
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultPassView = false  // 결과 뷰로 이동 제어
    @State private var navigateToContentView = false     // 콘텐츠 뷰로 이동 제어
    @State private var capturedImage: UIImage?          // 촬영된 이미지
    @State private var isCameraPresented = true         // 카메라 표시 여부
    @State private var passportResult: PassportResult?  // OCR 결과
    @State private var isLoading = false                // 로딩 표시
    @State private var showErrorAlert = false           // 에러 알림 표시
    @State private var errorMessage = ""                // 에러 메시지
    @State private var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    @State private var userId: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    @State private var showScanAlert = false            // 스캔 상태 알림
    @State private var scanAlertMessage = ""            // 스캔 상태 메시지
    @State private var isManualInput = false            // 수동 입력 모드
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false
    @AppStorage("SavedpassportData") private var savedpassportData: Data?
    // MARK: - 뷰 본문
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                Color.black.opacity(0.6).ignoresSafeArea()
                
                // 메인 컨텐츠
                VStack(spacing: 10) {
                    Spacer().frame(height: 10)
                    
                    // 안내 메시지
                    Text("Place your Passport within\nthe frame and tap the capture\nbutton to scan.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    // 이미지 프리뷰
                    ZStack {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 580, height: 380)
                                .cornerRadius(10)
                        } else {
                            Color.gray.opacity(0.1)
                                .frame(width: 580, height: 380)
                                .cornerRadius(10)
                        }
                    }
                    
                    // 버튼 그룹
                    HStack(spacing: 30) {
                        // 스캔 버튼
                        Button(action: {
                            if let image = capturedImage {
                                passportDataSaved = true
                                captureAndSendImage(image)
                                navigateToResultPassView = true
                            }
                            else {
                                showScanAlert = true
                                scanAlertMessage = "Please capture an image first"
                            }
                        }) {
                            Text("Scan")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 44)
                                .background(Capsule().fill(Color.blue))
                        }
                        
                        // 재촬영 버튼
                        Button(action: {
                            capturedImage = nil
                            isCameraPresented = true
                        }) {
                            Text("Re-take")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                                .frame(width: 100, height: 44)
                                .background(Capsule().fill(Color.white))
                        }
                    }.padding(.bottom, 10)
                    
                    // 수동 입력 버튼
                    Button(action: {
                        isManualInput = true
                    }) {
                        VStack(spacing: 4) {
                            Text("Manual input")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.top, 0)
                                .background(
                                    GeometryReader { geometry in
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 1)
                                            .foregroundColor(.white)
                                            .offset(y: 24)
                                    }
                                )
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                
                // 로딩 인디케이터
                if isLoading {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView().scaleEffect(2)
                }
            }
            .onAppear {
                isCameraPresented = true
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .imageScale(.large)
            })
            .sheet(isPresented: $isCameraPresented) {
                CameraCapturePassView(capturedImage: $capturedImage, isPresented: $isCameraPresented)
            }
            // 알림 설정
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showScanAlert) {
                Alert(
                    title: Text("Scan Status"),
                    message: Text(scanAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            // 네비게이션 링크
            NavigationLink(
                destination: ScanPassView(result: passportResult)
                    .onDisappear {
                        // 뷰가 사라질 때 결과값 유지
                        passportResult = passportResult
                    },
                isActive: $navigateToResultPassView
            ) {
                EmptyView()
            }
            NavigationLink(
                destination: ScanPassView(result: nil),
                isActive: $isManualInput
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ContentView(),
                isActive: $navigateToContentView
            ) {
                EmptyView()
            }
        }
    }
    
    // MARK: - 네트워크 함수
    /// 이미지 캡처 및 OCR API 요청 처리
    private func captureAndSendImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        print("📤 여권 OCR 요청 준비 중...")
        
        // API 요청 설정
        let url = URL(string: "http://43.203.237.202:18080/api/v1/naver-ocr")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // multipart/form-data 설정
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 요청 바디 구성
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\npassport\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"ext\"\r\n\r\njpg\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 OCR 요청 전송 중...")
        isLoading = true
        
        // API 요청 실행
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            // 에러 처리
            if let error = error {
                print("❌ 네트워크 에러: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                                return
                            }
                            
                            // 데이터 확인
                            guard let data = data else {
                                print("❌ 서버로부터 데이터를 받지 못함")
                                DispatchQueue.main.async {
                                    self.errorMessage = "No data received from server."
                                    self.showErrorAlert = true
                                }
                                return
                            }
                            
                            do {
                                // 디버깅을 위한 응답 데이터 출력
                                if let jsonString = String(data: data, encoding: .utf8) {
                                    print("📥 응답 JSON: \(jsonString)")
                                }
                                
                                // OCR 응답 디코딩 및 변환
                                let passportResponse = try JSONDecoder().decode(PassportNaverResponse.self, from: data)
                                let result = passportResponse.toPassportResult()
                                
                                print("✅ OCR 응답 수신:")
                                print("상태: \(result.status)")
                                print("메시지: \(result.message)")
                                
                                    if result.status == 200 {
                                        print("✅ 여권 OCR 성공")
                                        self.passportResult = result
                                        self.passportDataSaved = true
                                        self.navigateToResultPassView = true
                                    } else {
                                        print("❌ OCR 실패: \(result.message)")
                                        self.errorMessage = result.message
                                        self.showErrorAlert = true
                                      
                                    }

                            } catch {
                                print("❌ 디코딩 에러: \(error)")
                             
                                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                                    self.showErrorAlert = true
                                
                            }
                        }.resume()
                    }
                    
            
                }
