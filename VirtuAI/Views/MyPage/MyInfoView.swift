import SwiftUI
import AVFoundation

struct MyInfoView: View {
    // 기본 정보 필드
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
    @State private var signatureImage: UIImage? = nil
    @State private var showSignaturePad = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 저장 기능
    private func saveInfo() {
        let updateRequest = MemberUpdateRequest(
            phoneNumber: phoneNumber,
            annualIncome: Int(incomeAmount) ?? 0,
            workplaceName: originalWorkplaceName,
            workplaceRegistrationNumber: originalWorkplaceRegistrationNumber,
            workplacePhoneNumber: originalWorkplacePhoneNumber,
            futureWorkplaceName: futureWorkplaceName,
            futureWorkplaceRegistrationNumber: "",
            futureWorkplacePhoneNumber: futureWorkplacePhoneNumber,
            profileImageUrl: "https://example.com/profile.jpg",
            signatureUrl: "https://example.com/signature.png",
            koreaAddress: koreaAddress,
            telephoneNumber: telephoneNumber,
            homelandAddress: homelandAddress,
            homelandPhoneNumber: homelandPhoneNumber,
            schoolStatus: schoolStatus,
            schoolName: schoolName,
            schoolPhoneNumber: schoolPhoneNumber,
            schoolType: schoolType,
            originalWorkplaceName: originalWorkplaceName,
            originalWorkplaceRegistrationNumber: originalWorkplaceRegistrationNumber,
            originalWorkplacePhoneNumber: originalWorkplacePhoneNumber,
            incomeAmount: Int(incomeAmount) ?? 0,
            job: job,
            refundAccountNumber: refundAccountNumber
        )
        
        MInfoUpdateView().updateMemberInfo(updateRequest)
    }
   
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Information")
                        .font(.title)
                        .foregroundColor(.black)

                    Text("Please provide any information that cannot be determined from the ID.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading) {
                        SectionView(title: "Address in Korea", text: $koreaAddress)
                        SectionView(title: "Telephone No.", text: $telephoneNumber)
                        SectionView(title: "Cellphone No.", text: $phoneNumber)
                        SectionView(title: "Home Country Address", text: $homelandAddress)
                        SectionView(title: "Home Country Phone Number", text: $homelandPhoneNumber)
                        
                        DropdownInfoField(title: "Enrollment Status", selectedValue: $schoolStatus, options: ["High School", "University", "Other"], isRequired: true)
                        SectionView(title: "School Name", text: $schoolName)
                        SectionView(title: "School Phone Number", text: $schoolPhoneNumber)
                        
                        DropdownInfoField(title: "Type of School", selectedValue: $schoolType, options: ["Unaccredited by the Office of..", "Accredited by Government"], isRequired: true)
                        SectionView(title: "Previous Employer Name", text: $originalWorkplaceName)
                        SectionView(title: "Previous Employer Business Registration Number", text: $originalWorkplaceRegistrationNumber)
                        SectionView(title: "Previous Employer Phone Number", text: $originalWorkplacePhoneNumber)
                        SectionView(title: "Prospective Employer Name", text: $futureWorkplaceName)
                        SectionView(title: "Prospective Employer Phone Number", text: $futureWorkplacePhoneNumber)
                        SectionView(title: "Annual Income", text: $incomeAmount)
                        SectionView(title: "Occupation", text: $job)
                        SectionView(title: "Refund Account Number", text: $refundAccountNumber)
                        
                        VStack(alignment: .leading) {
                            Text("Upload ID Photo with White Background")
                                .font(.headline)
                            if let image = signatureImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(height: 150)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            } else {
                                Button(action: { showSignaturePad = true }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                        Text("Upload Image")
                                            .font(.subheadline)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 150)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    Button(action: saveInfo) {
                        Text("Save Info")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showSignaturePad) {
                SignatureMyInfoPadView(signatureImage: $signatureImage) { savedImage in
                    self.signatureImage = savedImage
                    self.saveImageToAlbum(savedImage)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveImageToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Signature saved to album."
        showAlert = true
    }
}

// SectionView 및 DropdownField 컴포넌트
struct SectionView: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            TextField("\(title)", text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}

struct DropdownInfoField: View {
    var title: String
    @Binding var selectedValue: String
    var options: [String]
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                if isRequired { Text("*").foregroundColor(.red) }
            }
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedValue = option
                    }) {
                        Text(option)
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.isEmpty ? "\(title)" : selectedValue)
                        .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            }
        }
    }
}

// 서명 입력창 및 관련 뷰
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
            
            SignatureMyInfoDrawView(drawing: $drawingPath)
                .frame(height: 200)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                .padding()
            
            HStack {
                Button(action: { drawingPath = DrawingMyInfoPath() }) {
                    Text("Reset")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                
                Button(action: {
                    let image = drawingPath.toImage()
                    onSave(image)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
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
}

struct SignatureMyInfoDrawView: View {
    @Binding var drawing: DrawingMyInfoPath
    
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

// 서명 데이터 모델 및 쉐이프
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
    
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
        return renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.drawPath(using: .stroke)
        }
    }
}

extension Path {
    var cgPath: CGPath {
        let path = CGMutablePath()
        forEach { element in
            switch element {
            case .move(let p):
                path.move(to: p)
            case .line(let p):
                path.addLine(to: p)
            case .quadCurve(let p1, let p2):
                path.addQuadCurve(to: p2, control: p1)
            case .curve(let p1, let p2, let p3):
                path.addCurve(to: p3, control1: p1, control2: p2)
            case .closeSubpath:
                path.closeSubpath()
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
