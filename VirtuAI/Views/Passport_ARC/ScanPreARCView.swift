import SwiftUI
import AVFoundation
import SwiftKeychainWrapper

// MARK: - 카메라 캡처 컴포넌트
/// SwiftUI에서 카메라 기능을 사용하기 위한 UIImagePickerController 래퍼
struct CameraCaptureARCView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?  // 촬영된 이미지를 저장
    @Binding var isPresented: Bool        // 카메라 뷰 표시 여부 제어
    
    // UIImagePickerController 생성 및 설정
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera  // 카메라 모드로 설정
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 카메라 작업을 처리하는 코디네이터 클래스
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCaptureARCView
        
        init(_ parent: CameraCaptureARCView) {
            self.parent = parent
        }
        
        // 이미지 촬영 완료 시 처리
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
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
struct OCRNaverResponse: Codable {
    let status: Int          // 응답 상태 코드
    let message: String      // 응답 메시지
    let data: OCRNaverData?  // OCR 결과 데이터
}

/// OCR로 추출된 외국인등록증 데이터 모델
struct OCRNaverData: Codable {
    let inferResult: String?   // OCR 추론 결과
    let gender: String?        // 성별
    let nationality: String?   // 국적
    let dateOfBirth: String?   // 생년월일
    let visa: String?          // 비자 종류
    let name: String?          // 이름
    let message: String?       // 추가 메시지
    let alienRegNum: String?   // 외국인등록번호
    let foreignRegistrationNumber: String? // 추가 필드
    let userId: String?         // 사용자 ID
    
    // JSON 매핑을 위한 코딩키
    enum CodingKeys: String, CodingKey {
        case inferResult
        case gender
        case nationality
        case dateOfBirth = "date_of_birth"
        case visa
        case name
        case message
        case alienRegNum
        case foreignRegistrationNumber
        case userId
    }
}

// MARK: - 모델 확장

/// OCRNaverResponse를 ARCResult로 변환하는 확장
extension OCRNaverResponse {
    func toARCResult() -> ARCResult {
        return ARCResult(
            status: self.status,
            message: self.message,
            data: ARCData(
                foreignRegistrationNumber: self.data?.foreignRegistrationNumber,
                dateOfBirth: self.data?.dateOfBirth,
                gender: self.data?.gender,
                name: self.data?.name,
                nationality: self.data?.nationality,
                issueCountry: nil,
                visaType: self.data?.visa,
                permitDate: nil,
                expirationDate: nil,
                residence: nil
            )
        )
    }
}

/// 외국인등록증 데이터 표준 결과 구조체
struct ARCResult: Codable {
    var status: Int
    var message: String
    var data: ARCData?
}

/// 외국인등록증 정보 데이터 모델
struct ARCData: Codable {
    // 필수 정보
    var foreignRegistrationNumber: String? // 외국인등록번호
    var dateOfBirth: String?              // 생년월일
    var gender: String?                   // 성별
    var name: String?                     // 이름
    var nationality: String?              // 국적
    
    // 추가 정보
    var issueCountry: String?             // 발급 국가
    var visaType: String?                 // 비자 종류
    var permitDate: String?               // 허가일자
    var expirationDate: String?           // 만료일자
    var residence: String?                // 거주지
    
    
    // JSON 매핑을 위한 코딩키
    enum CodingKeys: String, CodingKey {
        case foreignRegistrationNumber
        case dateOfBirth
        case gender
        case name
        case nationality
        case issueCountry
        case visaType = "visa"
        case permitDate
        case expirationDate
        case residence
    }
}

// MARK: - 메인 뷰
/// 외국인등록증 스캐닝 메인 뷰
struct ScanPreARCView: View {
    // MARK: 환경 및 상태 변수
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultView = false  // 결과 뷰로 이동 제어
    @State private var navigateToContentView = false // 콘텐츠 뷰로 이동 제어
    @State private var capturedImage: UIImage?      // 촬영된 이미지
    @State private var isCameraPresented = false    // 카메라 표시 여부
    @State private var arcResult: ARCResult?        // OCR 결과
    @State private var isLoading = false            // 로딩 표시
    @State private var showErrorAlert = false       // 에러 알림 표시
    @State private var errorMessage = ""            // 에러 메시지
    @State private var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    @State private var userId: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    @State private var showScanAlert = false        // 스캔 상태 알림
    @State private var scanAlertMessage = ""        // 스캔 상태 메시지
    @State private var isManualInput = false        // 수동 입력 모드
    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false // ARC 데이터 저장 상태
    @AppStorage("SavedarcData") private var savedARCData: Data?
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                Color.black.opacity(0.6).ignoresSafeArea()
                
                // 메인 컨텐츠
                VStack(spacing: 10) {
                    // 안내 메시지
                    Spacer().frame(height: 10)
                    Text("Place your ARC within\nthe frame and tap the capture\nbutton to scan.")
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
                    
                    // 액션 버튼
                    HStack(spacing: 30) {
                        // 스캔 버튼
                        Button(action: {
                            if let image = capturedImage {
                                    arcDataSaved = true
                                    captureAndSendImage(image)
                                    navigateToResultView = true
                                
                            } else {
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
            // 뷰 설정
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
            // 카메라 시트
            .sheet(isPresented: $isCameraPresented) {
                CameraCaptureARCView(capturedImage: $capturedImage, isPresented: $isCameraPresented)
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
                destination: ScanARCView(result: arcResult ?? ARCResult(
                    status: 0,
                    message: "",
                    data: ARCData()
                )),
                isActive: $navigateToResultView
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ScanARCView(result: ARCResult(
                    status: 0,
                    message: "",
                    data: ARCData()
                )),
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
        // 이미지 데이터 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // API 요청 설정
        let url = URL(string: "http://43.203.237.202:18080/api/v1/naver-ocr")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // multipart/form-data 바디 생성
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 요청 바디 구성
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\nidcard\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"ext\"\r\n\r\npng\r\n".data(using: .utf8)!)
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
                    self.errorMessage = "네트워크 에러: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                return
            }
            
            // 데이터 확인
            guard let data = data else {
                print("❌ 서버로부터 데이터를 받지 못함")
                DispatchQueue.main.async {
                    self.errorMessage = "서버로부터 데이터를 받지 못했습니다."
                    self.showErrorAlert = true
                }
                return
            }
            
            do {
                // OCR 응답 디코딩 및 변환
                let ocrResponse = try JSONDecoder().decode(OCRNaverResponse.self, from: data)
                let result = ocrResponse.toARCResult()
                
                print("✅ OCR 응답 수신:")
                print("상태: \(result.status)")
                print("메시지: \(result.message)")
                
                // 결과 처리
         
                    if result.status == 200 {
                        print("✅ 유효한 OCR 데이터 수신, 결과 뷰로 이동")
                        if let encoded = try? JSONEncoder().encode(result) {
                                                   savedARCData = encoded
                                               }
                        self.arcResult = result
                        self.arcDataSaved = true
                        self.navigateToResultView = true
                    } else {
                        print("❌ 유효하지 않은 OCR 데이터")
                        self.errorMessage = "유효한 OCR 데이터를 받지 못했습니다."
                        self.showErrorAlert = true
                    }
                
            } catch {
                print("❌ 디코딩 에러: \(error)")
                    self.errorMessage = "응답 디코딩 실패: \(error)"
                    self.showErrorAlert = true
                
            }
        }.resume()
    }
}
