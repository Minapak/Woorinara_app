import SwiftUI
import AVFoundation
import SwiftKeychainWrapper
// 카메라 프리뷰 및 이미지 촬영
struct CameraCaptureARCView: UIViewControllerRepresentable {
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
        let parent: CameraCaptureARCView

        init(_ parent: CameraCaptureARCView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// OCR API 응답 모델
struct OCRResult: Codable {
    var status: Int
    var message: String
    var data: OCRData
}

struct OCRData: Codable {
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

// Main view for scanning the ARC
struct ScanPreARCView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultView = false
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var ocrResult: OCRResult?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    
    var body: some View {
        NavigationStack {
            ZStack {
               // Color.white.ignoresSafeArea()
                // Assets에 있는 "background" 이미지로 배경 설정
                               Image("background")
                                   .resizable()
                                   .scaledToFill()
                                   .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer().frame(height: 50)

                    Text("Place your ARC within\nthe frame and tap the capture\nbutton to scan.")
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
        }
    }

    private func captureAndSendImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let url = URL(string: "http://43.203.237.202:18080/api/v1/naver-ocr")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\nidcard\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"ext\"\r\n\r\npng\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }

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
                let result = try JSONDecoder().decode(OCRResult.self, from: data)
                DispatchQueue.main.async {
                    self.ocrResult = result
                    self.navigateToResultView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error)"
                    self.showErrorAlert = true
                }
            }
        }.resume()
    }
}

struct ScanPreARCView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScanPreARCView()
        }
    }
}
