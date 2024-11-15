import SwiftUI
import AVFoundation
import SwiftKeychainWrapper

// Camera Capture Component
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

// OCR Result Model
struct OCRResult: Codable {
    var status: Int
    var message: String
    var data: OCRData?
}

struct OCRData: Codable {
    var inferResult: String?
    var gender: String?
    var nationality: String?
    var dateOfBirth: String?
    var visa: String?
    var name: String?
    var message: String?
    var alienRegNum: String?
    var userId: String?
}

// Main View for ARC Scanning
struct ScanPreARCView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToResultView = false
    @State private var navigateToContentView = false // For navigating back to ContentView
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false
    @State private var ocrResult: OCRResult?
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var authToken: String = KeychainWrapper.standard.string(forKey: "accessToken") ?? "DefaultAccessToken"
    @State private var isManualInput = false
    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.6).ignoresSafeArea()

                VStack(spacing: 10) {
                    Spacer().frame(height: 10)
                    Text("Place your ARC within\nthe frame and tap the capture\nbutton to scan.")
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
                            arcDataSaved = true // Simulate saving ARC data
                            navigateToResultView = true
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
                CameraCaptureARCView(capturedImage: $capturedImage, isPresented: $isCameraPresented)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
            NavigationLink(
                destination: ScanARCView(result: ocrResult ?? OCRResult(status: 0, message: "", data: OCRData())),
                isActive: $navigateToResultView
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ScanARCView(result: OCRResult(status: 0, message: "", data: OCRData())),
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
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

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
                let result = try JSONDecoder().decode(OCRResult.self, from: data)
                DispatchQueue.main.async {
                    if result.status == 200, result.data != nil {
                        self.ocrResult = result
                        self.navigateToResultView = true
                    } else {
                        self.errorMessage = "No valid OCR data received."
                        self.showErrorAlert = true
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
}
