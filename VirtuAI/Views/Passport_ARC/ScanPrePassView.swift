import SwiftUI
import SwiftKeychainWrapper
import AVFoundation

// OCR API 응답 모델
struct OCRPassResult: Codable {
    var status: Int
    var message: String
    var data: OCRPassData?
}

struct OCRPassData: Codable {
    var dateOfExpiry: String?
    var inferResult: String?
    var surName: String?
    var nationality: String?
    var gender: String?
    var documentNumber: String?
    var givenName: String?
    var issueCountry: String?
    var middleName: String?
    var dateOfBirth: String?
    var message: String?
    var userId: String?
}

// 카메라 프리뷰 및 이미지 촬영
struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool

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

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCaptureView

        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
                // Save the image to the photo album
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// 여권 정보를 스캔하고 서버에 전송하는 메인 View
struct ScanPrePassView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultPassView = false
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var ocrPassResult: OCRPassResult?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background") // Assets에 있는 "background" 이미지로 배경 설정
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer().frame(height: 50)

                    Text("Place your Passport within the frame and tap the capture button to scan.")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    ZStack {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 280, height: 180)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                        } else {
                            Color.gray.opacity(0.1)
                                .frame(width: 280, height: 180)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 3)
                                )
                        }
                    }
                    
                    Button(action: {
                        isCameraPresented = true
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.white.opacity(0.1)).frame(width: 90, height: 90))
                    }
                    
                    Button("Send Image for OCR") {
                        if let image = capturedImage {
                            captureAndSendImage(image)
                        } else {
                            errorMessage = "No image captured."
                            showErrorAlert = true
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                    .disabled(capturedImage == nil)
                    .padding(.top, 20)
                }
                
                if isLoading {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView().scaleEffect(2)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .imageScale(.large)
                Text("")
                    .foregroundColor(.blue)
            })
            .sheet(isPresented: $isCameraPresented) {
                CameraCaptureView(capturedImage: $capturedImage, isPresented: $isCameraPresented)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
            NavigationLink(
                destination: ocrPassResult.map { ScanPassView(result: $0) },
                isActive: $navigateToResultPassView
            ) {
                EmptyView() // NavigationLink를 위한 EmptyView
            }
        }
    }

    private func captureAndSendImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let url = URL(string: "http://43.203.237.202:18080/api/v1/naver-ocr")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.authToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\npassport\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"ext\"\r\n\r\npng\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server."
                    self.showErrorAlert = true
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(OCRPassResult.self, from: data)
                DispatchQueue.main.async {
                    if result.status == 200, let data = result.data, data.surName != nil || data.givenName != nil || data.documentNumber != nil {
                        // OCRPassResult 값 출력
                        print("OCRPassResult 값들 :", result)
                                               
                        self.ocrPassResult = self.convertNilValues(result)
                        self.navigateToResultPassView = true
                    } else {
                        // 필수 데이터 누락 시 알림 및 재시도 메시지
                        self.errorMessage = "\(result.data?.userId ?? "User")님, OCR 결과를 추출하지 못했습니다. 다시 시도하십시오."
                        self.showErrorAlert = true
                        self.resetScanPrePassView()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error)"
                    self.showErrorAlert = true
                }
            }
        }.resume()
    }

    private func convertNilValues(_ result: OCRPassResult) -> OCRPassResult {
        // 각 속성을 개별 상수로 복사한 후, 변경된 값으로 새로운 OCRPassData 객체 생성
        let dateOfExpiry = result.data?.dateOfExpiry ?? ""
        let inferResult = result.data?.inferResult ?? ""
        let surName = result.data?.surName ?? ""
        let nationality = result.data?.nationality ?? ""
        let gender = result.data?.gender == "M" ? "M" : (result.data?.gender == "F" ? "F" : "")
        let documentNumber = result.data?.documentNumber ?? ""
        let givenName = result.data?.givenName ?? ""
        let issueCountry = result.data?.issueCountry ?? ""
        let middleName = result.data?.middleName ?? ""
        let dateOfBirth = result.data?.dateOfBirth ?? ""
        let message = result.data?.message ?? ""
        let userId = result.data?.userId ?? ""

        // 수정된 값들로 새로운 OCRPassData 객체를 생성하여 반환
        let modifiedData = OCRPassData(
            dateOfExpiry: dateOfExpiry,
            inferResult: inferResult,
            surName: surName,
            nationality: nationality,
            gender: gender,
            documentNumber: documentNumber,
            givenName: givenName,
            issueCountry: issueCountry,
            middleName: middleName,
            dateOfBirth: dateOfBirth,
            message: message,
            userId: userId
        )
        
        return OCRPassResult(status: result.status, message: result.message, data: modifiedData)
    }

    // ScanPrePassView 초기화
    private func resetScanPrePassView() {
        self.capturedImage = nil
        self.ocrPassResult = nil
        self.navigateToResultPassView = false
    }
}

struct ScanPrePassView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScanPrePassView()
        }
    }
}
