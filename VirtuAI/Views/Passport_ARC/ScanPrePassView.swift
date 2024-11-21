import SwiftUI
import SwiftKeychainWrapper
import AVFoundation

struct OCRPassResult: Codable {
    var status: Int
    var message: String
    var data: OCRPassData?
    
    init(status: Int, message: String, data: OCRPassData?) {
        self.status = status
        self.message = message
        self.data = data
    }
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
    
    enum CodingKeys: String, CodingKey {
        case dateOfExpiry = "dateOfExpiry"
        case inferResult = "inferResult"
        case surName = "surName"
        case nationality = "nationality"
        case gender = "gender"
        case documentNumber = "documentNum" // API 응답의 실제 키 이름으로 수정
        case givenName = "givenName"
        case issueCountry = "issueCountry"
        case middleName = "middleName"
        case dateOfBirth = "dateOfBirth"
        case message = "message"
        case userId = "userId"
    }
    
    init() {
        self.dateOfExpiry = nil
        self.inferResult = nil
        self.surName = nil
        self.nationality = nil
        self.gender = nil
        self.documentNumber = nil
        self.givenName = nil
        self.issueCountry = nil
        self.middleName = nil
        self.dateOfBirth = nil
        self.message = nil
        self.userId = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        dateOfExpiry = try container.decodeIfPresent(String.self, forKey: .dateOfExpiry)
        inferResult = try container.decodeIfPresent(String.self, forKey: .inferResult)
        surName = try container.decodeIfPresent(String.self, forKey: .surName)
        nationality = try container.decodeIfPresent(String.self, forKey: .nationality)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        documentNumber = try container.decodeIfPresent(String.self, forKey: .documentNumber)
        givenName = try container.decodeIfPresent(String.self, forKey: .givenName)
        issueCountry = try container.decodeIfPresent(String.self, forKey: .issueCountry)
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        dateOfBirth = try container.decodeIfPresent(String.self, forKey: .dateOfBirth)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
    
    init(dateOfExpiry: String? = nil,
         inferResult: String? = nil,
         surName: String? = nil,
         nationality: String? = nil,
         gender: String? = nil,
         documentNumber: String? = nil,
         givenName: String? = nil,
         issueCountry: String? = nil,
         middleName: String? = nil,
         dateOfBirth: String? = nil,
         message: String? = nil,
         userId: String? = nil) {
        self.dateOfExpiry = dateOfExpiry
        self.inferResult = inferResult
        self.surName = surName
        self.nationality = nationality
        self.gender = gender
        self.documentNumber = documentNumber
        self.givenName = givenName
        self.issueCountry = issueCountry
        self.middleName = middleName
        self.dateOfBirth = dateOfBirth
        self.message = message
        self.userId = userId
    }
}

// Camera Preview and Image Capture
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
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct ScanPrePassView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultPassView = false
    @State private var navigateToContentView = false // New state for "Skip" button
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = true
    @State private var ocrPassResult: OCRPassResult?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    @State private var showScanAlert = false // 추가
    @State private var scanAlertMessage = "" // 추가
    @State private var isManualInput = false
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.6).ignoresSafeArea()

                VStack(spacing: 10) {
                    Spacer().frame(height: 10)

                    // Instruction Text
                    Text("Place your Passport within \nthe frame and tap the capture \nbutton to scan.")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

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

                    HStack(spacing:30) {
                        Button(action: {
                            if let image = capturedImage {
                                showScanAlert = true
                                scanAlertMessage = "Passport scan completed successfully!"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    passportDataSaved = true
                                    navigateToResultPassView = true
                                }
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

                    Button(action: {
                        isManualInput = true
                    }) {
                        VStack(spacing: 4) { // Adjust spacing if needed
                            Text("Manual input")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.top, 0)
                                .background(
                                    GeometryReader { geometry in
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 1) // Match width of the text
                                            .foregroundColor(.white)
                                            .offset(y: 24) // Position the line just below the text
                                    }
                                )
                        }
                        .fixedSize(horizontal: true, vertical: false) // Prevents VStack from expanding
                    }

                
                }
                
                // Loading Overlay
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
                CameraCaptureView(capturedImage: $capturedImage, isPresented: $isCameraPresented)
            }
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
            
            NavigationLink(
                destination: ScanPassView(result: ocrPassResult ?? OCRPassResult(status: 0, message: "", data: OCRPassData())),
                isActive: $navigateToResultPassView
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ScanPassView(result: OCRPassResult(status: 0, message: "", data: OCRPassData())),
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
                        self.ocrPassResult = self.convertNilValues(result)
                        self.navigateToResultPassView = true
                    } else {
                        self.errorMessage = "OCR result extraction failed. Please try again."
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
        let modifiedData = OCRPassData(
            dateOfExpiry: result.data?.dateOfExpiry ?? "",
            inferResult: result.data?.inferResult ?? "",
            surName: result.data?.surName ?? "",
            nationality: result.data?.nationality ?? "",
            gender: result.data?.gender == "M" ? "M" : (result.data?.gender == "F" ? "F" : ""),
            documentNumber: result.data?.documentNumber ?? "",
            givenName: result.data?.givenName ?? "",
            issueCountry: result.data?.issueCountry ?? "",
            middleName: result.data?.middleName ?? "",
            dateOfBirth: result.data?.dateOfBirth ?? "",
            message: result.data?.message ?? "",
            userId: result.data?.userId ?? ""
        )
        
        return OCRPassResult(status: result.status, message: result.message, data: modifiedData)
    }

    private func resetScanPrePassView() {
        self.capturedImage = nil
        self.ocrPassResult = nil
        self.navigateToResultPassView = false
    }
}
