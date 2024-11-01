import SwiftUI
import AVFoundation

struct ContentSignView: View {
    @State private var image: UIImage? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var koreaAddress: String = ""
    @State private var telephoneNumber: String = ""
    @State private var homeCountryAddress: String = ""
    @State private var homeCountryPhoneNumber: String = ""
    @State private var enrollmentStatus: String = "High School"
    @State private var schoolName: String = ""
    @State private var schoolPhoneNumber: String = ""
    @State private var typeOfSchool: String = "Unaccredited by the Office of.."
    @State private var previousEmployerName: String = ""
    @State private var previousEmployerRegNum: String = ""
    @State private var prospectiveEmployerName: String = ""
    @State private var prospectiveEmployerRegNum: String = ""
    @State private var prospectiveEmployerPhone: String = ""
    @State private var annualIncome: String = ""
    @State private var occupation: String = ""
    @State private var refundAccountNumber: String = ""
    @State private var uploadIDPhoto: String = ""
    @FocusState private var isFocused: Bool // Focus 상태 관리
    @State private var showingSignaturePad = false // 서명 패드 표시 상태
    @State private var signatureImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Please provide any information that cannot be determined from the ID.")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Address in Korea")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#5C6366"))
                        textFieldStyle("Please enter the content.", text: $koreaAddress)
                    }
                    
                    // Additional fields follow similar pattern
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Telephone No.")
                            .font(.headline)
                        textFieldStyle("Please enter the content.", text: $telephoneNumber)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Home Country Address")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#5C6366"))
                        textFieldStyle("Please enter the content.", text: $homeCountryAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Home Country Phone Number")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#5C6366"))
                        textFieldStyle("Please enter the content.", text: $homeCountryPhoneNumber)
                    }
                    
                    VStack {
                        // 서명창으로 이동 버튼
                        Button(action: {
                            showingSignaturePad = true
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .sheet(isPresented: $showingSignaturePad) {
                        SignaturePadView(signatureImage: $signatureImage, onSave: handleSignatureSave)
                    }
                    
                    if let savedImage = image {
                        Image(uiImage: savedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 100)
                    }
                }
                .padding()
            }
        }
    }
    
    // 서명 저장 후 실행할 작업
    private func handleSignatureSave(_ savedImage: UIImage) {
        self.image = savedImage
        saveImageToAlbum(savedImage)
        uploadSignatureImage(savedImage)
    }
    
    // 텍스트 필드 스타일을 중복 사용하지 않기 위한 함수
    private func textFieldStyle(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(
            placeholder,
            text: text
        )
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .focused($isFocused)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused || !text.wrappedValue.isEmpty ? Color(hex: "#3B8AFF") : Color(hex: "#B4BAC2"), lineWidth: 1)
        )
        .onChange(of: text.wrappedValue) { newValue in
            if newValue.isEmpty {
                isFocused = false
            }
        }
        .foregroundColor(text.wrappedValue.isEmpty ? Color(hex: "#5C687A") : Color(hex: "#5C687A"))
        .lineLimit(1)
        .truncationMode(.tail)
    }
    
    // Function to save image to photo album
    private func saveImageToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Signature saved to album."
        showAlert = true
    }
    
    // Function to upload signature image with multipart/form-data
    private func uploadSignatureImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to convert image to data."
            showAlert = true
            return
        }
        
        let url = URL(string: "http://43.203.237.202:18080/api/v1/s3/sign")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"signature.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Upload Error: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        alertMessage = "Signature uploaded successfully."
                    } else {
                        alertMessage = "Upload failed with status code: \(httpResponse.statusCode)"
                    }
                    showAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Unexpected response type."
                    showAlert = true
                }
            }
        }.resume()
    }
}

// 서명 입력 창을 위한 뷰
struct SignaturePadView: View {
    @Binding var signatureImage: UIImage?
    var onSave: (UIImage) -> Void
    @State private var drawingPath = DrawingPath()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Enter Signature")
                .font(.headline)
                .padding()
            
            // 서명 입력 영역
            SignatureDrawView(drawing: $drawingPath)
                .frame(height: 200)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                .padding()
            
            HStack {
                Button(action: resetSignature) {
                    Text("Reset")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                
                Button(action: {
                    saveSignature()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
    private func resetSignature() {
        drawingPath = DrawingPath()
    }
    
    private func saveSignature() {
        let path = drawingPath.cgPath
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
        let image = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.addPath(path)
            ctx.cgContext.drawPath(using: .stroke)
        }
        onSave(image)
    }
}

// 서명 입력을 위한 뷰
struct SignatureDrawView: View {
    @Binding var drawing: DrawingPath
    @State private var drawingBounds: CGRect = .zero
    
    var body: some View {
        ZStack {
            Color.white
            if drawing.isEmpty {
                Text("Please enter the signature to be used for document creation.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                DrawShape(drawingPath: drawing)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.black)
            }
        }
        .gesture(DragGesture()
            .onChanged { value in
                drawing.addPoint(value.location)
            }
            .onEnded { _ in
                drawing.addBreak()
            })
    }
}

struct DrawShape: Shape {
    let drawingPath: DrawingPath
    
    func path(in rect: CGRect) -> Path {
        drawingPath.path
    }
}

struct DrawingPath {
    private(set) var points = [CGPoint]()
    private var breaks = [Int]()
    
    var isEmpty: Bool {
        points.isEmpty
    }
    
    mutating func addPoint(_ point: CGPoint) {
        points.append(point)
    }
    
    mutating func addBreak() {
        breaks.append(points.count)
    }
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        guard let firstPoint = points.first else { return path }
        path.move(to: firstPoint)
        for i in 1..<points.count {
            if breaks.contains(i) {
                path.move(to: points[i])
            } else {
                path.addLine(to: points[i])
            }
        }
        return path
    }
    
    var path: Path {
        var path = Path()
        guard let firstPoint = points.first else { return path }
        path.move(to: firstPoint)
        for i in 1..<points.count {
            if breaks.contains(i) {
                path.move(to: points[i])
            } else {
                path.addLine(to: points[i])
            }
        }
        return path
    }
}

struct ContentSignView_Previews: PreviewProvider {
    static var previews: some View {
        ContentSignView()
    }
}
