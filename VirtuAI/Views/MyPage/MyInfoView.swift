import SwiftUI
import AVFoundation

struct MyInfoView: View {
    @State private var image: UIImage? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var koreaAddress: String = "City Plaza, 4th-7th floors, 17 Gukjegeumyung-ro 2-gil, Yeongdeungpo-gu, Seoul Special City"
    @State private var telephoneNumber: String = "02-1234-5677"
    @State private var phoneNumber: String = "010-1234-5678"
    @State private var homelandAddress: String = "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923"
    @State private var homelandPhoneNumber: String = "06-1234-1234"
    @State private var schoolStatus: String = "High School"
    @State private var schoolName: String = "Fafa school"
    @State private var schoolPhoneNumber: String = "06-1234-1234"
    @State private var schoolType: String = "Unaccredited by the Office of.."
    @State private var originalWorkplaceName: String = "Fafa Inc"
    @State private var originalWorkplaceRegistrationNumber: String = "123456789"
    @State private var originalWorkplacePhoneNumber: String = "02-1234-9876"
    @State private var futureWorkplaceName: String = ""
    @State private var futureWorkplacePhoneNumber: String = ""
    @State private var incomeAmount: String = "5000 ten thousand won"
    @State private var job: String = ""
    @State private var refundAccountNumber: String = "KOOKMIN, 123456-12-34566"
    @State private var uploadIDPhoto: UIImage? = nil
    @FocusState private var isFocused: Bool
    @State private var showSignaturePad: Bool = false
    @State private var showAFAutoView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                    Text("My Information")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("Please provide any information that cannot be determined from the ID.")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)

                    VStack(alignment: .leading) {
                        // 각 필드 섹션
                        SectionView(title: "Address in Korea", text: $koreaAddress)
                        SectionView(title: "Telephone No.", text: $telephoneNumber)
                        SectionView(title: "Cellphone No.", text: $phoneNumber)
                        SectionView(title: "Home Country Address", text: $homelandAddress)
                        SectionView(title: "Home Country Phone Number", text: $homelandPhoneNumber)
                        
                        // 드롭다운 섹션 예시 (Enrollment Status)
                        DropdownField(title: "Enrollment Status", selectedValue: $schoolStatus, options: ["High School", "University", "Other"], isRequired: true)
                        SectionView(title: "School Name", text: $schoolName)
                        SectionView(title: "School Phone Number", text: $schoolPhoneNumber)
                        
                        DropdownField(title: "Type of School", selectedValue: $schoolType, options: ["Unaccredited by the Office of..", "Accredited by Government"], isRequired: true)
                        SectionView(title: "Previous Employer Name", text: $originalWorkplaceName)
                        SectionView(title: "Previous Employer Business Registration Number", text: $originalWorkplaceRegistrationNumber)
                        SectionView(title: "Previous Employer Phone Number", text: $originalWorkplacePhoneNumber)
                        SectionView(title: "Prospective Employer Name", text: $futureWorkplaceName)
                        SectionView(title: "Prospective Employer Phone Number", text: $futureWorkplacePhoneNumber)
                        SectionView(title: "Annual Income", text: $incomeAmount, placeholder: "ten thousand won")
                        SectionView(title: "Occupation", text: $job)
                        SectionView(title: "Refund Account Number", text: $refundAccountNumber)
                        
                        VStack(alignment: .leading) {
                            Text("Upload ID Photo with White Background")
                                .font(.headline)
                            if let image = uploadIDPhoto {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            } else {
                                Button(action: { showSignaturePad = true }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
                                        Text("Upload Image")
                                            .font(.system(size: 16))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    HStack {
                        Button("Retry") {
                            resetFields()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))

                        Button("Next") {
                            // Next action
                            showAFAutoView = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .imageScale(.large)
                            Text("")
                                .foregroundColor(.black)
                        })
            
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showSignaturePad) {
                SignatureMyInfoPadView(signatureImage: $uploadIDPhoto) { savedImage in
                    handleSignatureMyInfoSave(savedImage)
                }
                
            }
            .background(
                NavigationLink(destination: AFAutoView(), isActive: $showAFAutoView) { EmptyView() }
                )
        }
    }

    private func handleSignatureMyInfoSave(_ savedImage: UIImage) {
        self.uploadIDPhoto = savedImage
        saveMyInfoImageToAlbum(savedImage)
        uploadMyInfoSignatureImage(savedImage)
    }

    private func resetFields() {
        koreaAddress = "City Plaza, 4th-7th floors, 17 Gukjegeumyung-ro 2-gil, Yeongdeungpo-gu, Seoul Special City"
        telephoneNumber = "02-1234-5677"
        phoneNumber = "010-1234-5678"
        homelandAddress = "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923"
        homelandPhoneNumber = "06-1234-1234"
        schoolStatus = "High School"
        schoolName = "Fafa school"
        schoolPhoneNumber = "06-1234-1234"
        schoolType = "Unaccredited by the Office of.."
        originalWorkplaceName = "Fafa Inc"
        originalWorkplaceRegistrationNumber = "123456789"
        originalWorkplacePhoneNumber = "02-1234-9876"
        futureWorkplaceName = ""
        futureWorkplacePhoneNumber = ""
        incomeAmount = "5000 ten thousand won"
        job = ""
        refundAccountNumber = "KOOKMIN, 123456-12-34566"
        uploadIDPhoto = nil
    }
    
    struct SectionView: View {
        var title: String
        @Binding var text: String
        var placeholder: String = "Please enter the content."
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#5C6366"))
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .foregroundColor(.black)
            }.frame(maxWidth: .infinity)
        }
    }

    struct DropdownField: View {
        var title: String
        @Binding var selectedValue: String
        var options: [String]
        var isRequired: Bool = false
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .opacity(0.7)
                    if isRequired { Text("*").foregroundColor(.red) }
                }
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedValue = option
                        }) {
                            Text(option)
                                .font(.system(size: 16))
                                .opacity(0.7)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedValue.isEmpty ? "Select" : selectedValue)
                            .font(.system(size: 16))
                            .opacity(0.7)
                            .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 1))
                }
            }
        }
    }

    private func saveMyInfoImageToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Signature saved to album."
        showAlert = true
    }
    
    private func uploadMyInfoSignatureImage(_ image: UIImage) {
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
struct SignatureMyInfoPadView: View {
    @Binding var signatureImage: UIImage?
    var onSave: (UIImage) -> Void
    @State private var drawingPath = DrawingMyInfoPath()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Enter Signature")
                .font(.headline)
                .padding()
            
            // 서명 입력 영역
            SignatureMyInfoDrawView(drawing: $drawingPath)
                .frame(height: 200)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                .padding()
            
            HStack {
                Button(action: resetMyInfoSignature) {
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
                    saveMyInfoSignature()
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
    
    private func resetMyInfoSignature() {
        drawingPath = DrawingMyInfoPath()
    }
    
    private func saveMyInfoSignature() {
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
struct SignatureMyInfoDrawView: View {
    @Binding var drawing: DrawingMyInfoPath
    @State private var drawingBounds: CGRect = .zero
    
    var body: some View {
        ZStack {
            Color.white
            if drawing.isEmpty {
                Text("Please enter the signature to be used for document creation.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                DrawMyInfoShape(drawingPath: drawing)
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

struct DrawMyInfoShape: Shape {
    let drawingPath: DrawingMyInfoPath
    
    func path(in rect: CGRect) -> Path {
        drawingPath.path
    }
}

struct DrawingMyInfoPath {
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

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MyInfoView()
    }
}
