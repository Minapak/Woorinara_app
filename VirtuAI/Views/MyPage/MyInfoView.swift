import SwiftUI
import AVFoundation
import VComponents
import SwiftKeychainWrapper

struct MyInfoView: View {
    @AppStorage("myInfoDataSaved") private var myInfoDataSaved: Bool = false
    @State private var koreaAddress: String = ""
    @State private var telephoneNumber: String = ""
    @State private var phoneNumber: String = ""
    @State private var homelandAddress: String = ""
    @State private var homelandPhoneNumber: String = ""
    @State private var schoolStatus: String = ""
    @State private var schoolName: String = ""
    @State private var schoolPhoneNumber: String = ""
    @State private var schoolType: String = ""
    @State private var originalWorkplaceName: String = ""
    @State private var originalWorkplaceRegistrationNumber: String = ""
    @State private var originalWorkplacePhoneNumber: String = ""
    @State private var futureWorkplaceName: String = ""
    @State private var futureWorkplacePhoneNumber: String = ""
    @State private var incomeAmount: String = ""
    @State private var job: String = ""
    @State private var refundAccountNumber: String = ""
    @State private var signatureImage: UIImage? = nil
    @State private var showSignaturePad = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showContentView = false // Navigation flag
    @State private var isLoading = false

    let endpoint = "http://43.203.237.202:18080/api/v1/members/details"
    
    private func fetchData() {
        guard let url = URL(string: endpoint),
              let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("Invalid URL or missing access token.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                DispatchQueue.main.async {
                    self.koreaAddress = decodedData["koreaAddress"] ?? ""
                    self.telephoneNumber = decodedData["telephoneNumber"] ?? ""
                    self.phoneNumber = decodedData["phoneNumber"] ?? ""
                    self.homelandAddress = decodedData["homelandAddress"] ?? ""
                    self.homelandPhoneNumber = decodedData["homelandPhoneNumber"] ?? ""
                    self.schoolStatus = decodedData["schoolStatus"] ?? ""
                    self.schoolName = decodedData["schoolName"] ?? ""
                    self.schoolPhoneNumber = decodedData["schoolPhoneNumber"] ?? ""
                    self.schoolType = decodedData["schoolType"] ?? ""
                    self.originalWorkplaceName = decodedData["originalWorkplaceName"] ?? ""
                    self.originalWorkplaceRegistrationNumber = decodedData["originalWorkplaceRegistrationNumber"] ?? ""
                    self.originalWorkplacePhoneNumber = decodedData["originalWorkplacePhoneNumber"] ?? ""
                    self.futureWorkplaceName = decodedData["futureWorkplaceName"] ?? ""
                    self.futureWorkplacePhoneNumber = decodedData["futureWorkplacePhoneNumber"] ?? ""
                    self.incomeAmount = decodedData["incomeAmount"] ?? ""
                    self.job = decodedData["job"] ?? ""
                    self.refundAccountNumber = decodedData["refundAccountNumber"] ?? ""
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func resetFields() {
        koreaAddress = ""
        telephoneNumber = ""
        phoneNumber = ""
        homelandAddress = ""
        homelandPhoneNumber = ""
        schoolStatus = ""
        schoolName = ""
        schoolPhoneNumber = ""
        schoolType = ""
        originalWorkplaceName = ""
        originalWorkplaceRegistrationNumber = ""
        originalWorkplacePhoneNumber = ""
        futureWorkplaceName = ""
        futureWorkplacePhoneNumber = ""
        incomeAmount = ""
        job = ""
        refundAccountNumber = ""
        signatureImage = nil
    }

    private func saveData() {
        let myInfoData: [String: String] = [
            "koreaAddress": koreaAddress,
            "telephoneNumber": telephoneNumber,
            "phoneNumber": phoneNumber,
            "homelandAddress": homelandAddress,
            "homelandPhoneNumber": homelandPhoneNumber,
            "schoolStatus": schoolStatus,
            "schoolName": schoolName,
            "schoolPhoneNumber": schoolPhoneNumber,
            "schoolType": schoolType,
            "originalWorkplaceName": originalWorkplaceName,
            "originalWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "originalWorkplacePhoneNumber": originalWorkplacePhoneNumber,
            "futureWorkplaceName": futureWorkplaceName,
            "futureWorkplacePhoneNumber": futureWorkplacePhoneNumber,
            "incomeAmount": incomeAmount,
            "job": job,
            "refundAccountNumber": refundAccountNumber
        ]

        do {
            let encodedData = try JSONEncoder().encode(myInfoData)
            UserDefaults.standard.set(encodedData, forKey: "SavedMyInfoData")
            myInfoDataSaved = true
            alertMessage = "Your information has been saved successfully."
        } catch {
            alertMessage = "Failed to save your information: \(error.localizedDescription)"
        }

        showAlert = true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Information")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("Please provide any information that cannot be determined from the ID.")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)

                    VStack(alignment: .leading) {
                        Spacer()
                        SectionInfoView(title: "Address in Korea", text: $koreaAddress, placeholder: "Seoul Special City")
                        Spacer()
                                           SectionInfoView(title: "Telephone No.", text: $telephoneNumber, placeholder: "02-1234-5677")
                        Spacer()
                                           SectionInfoView(title: "Cellphone No.", text: $phoneNumber, placeholder: "010-1234-5678")
                        Spacer()
                                           SectionInfoView(title: "Home Country Address", text: $homelandAddress, placeholder: "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923")
                        Spacer()
                                           SectionInfoView(title: "Home Country Phone Number", text: $homelandPhoneNumber, placeholder: "06-1234-1234")
                        Spacer()
                                           DropdownInfoField(title: "Enrollment Status", selectedValue: $schoolStatus, options: ["High School", "University", "Other"], placeholder: "High School", isRequired: true)
                        Spacer()
                                           SectionInfoView(title: "School Name", text: $schoolName, placeholder: "Fafa School")
                        Spacer()
                                           SectionInfoView(title: "School Phone Number", text: $schoolPhoneNumber, placeholder: "06-1234-1234")
                        Spacer()
                                           DropdownInfoField(title: "Type of School", selectedValue: $schoolType, options: ["Unaccredited", "Accredited"], placeholder: "Unaccredited by the Office of..", isRequired: true)
                        Spacer()
                                           SectionInfoView(title: "Previous Employer Name", text: $originalWorkplaceName, placeholder: "Fafa Inc")
                        Spacer()
                                           SectionInfoView(title: "Previous Employer Business Registration Number", text: $originalWorkplaceRegistrationNumber, placeholder: "123456789")
                        Spacer()
                                           SectionInfoView(title: "Previous Employer Phone Number", text: $originalWorkplacePhoneNumber, placeholder: "02-1234-9876")
                        Spacer()
                                           SectionInfoView(title: "Prospective Employer Name", text: $futureWorkplaceName, placeholder: "Enter employer name")
                        Spacer()
                                           SectionInfoView(title: "Prospective Employer Phone Number", text: $futureWorkplacePhoneNumber, placeholder: "Enter phone number")
                        Spacer()
                                           SectionInfoView(title: "Annual Income", text: $incomeAmount, placeholder: "5000 ten thousand won")
                        Spacer()
                                           SectionInfoView(title: "Occupation", text: $job, placeholder: "Enter your occupation")
                        Spacer()
                                           SectionInfoView(title: "Refund Account Number", text: $refundAccountNumber, placeholder: "KOOKMIN, 123456-12-34566")
                        Spacer()


                        VStack(alignment: .leading) {
                            Text("Enter Signature")
                                .font(.headline)
                            if let image = signatureImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            } else {
                                Button(action: { showSignaturePad = true }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }

                    Spacer()

                    HStack {
                        Button("Retry") {
                            resetFields()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))

                        Button("Done") {
                            saveData()
                            showContentView = true
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
            .sheet(isPresented: $showSignaturePad) {
                SignatureMyInfoPadView(signatureImage: $signatureImage) { savedImage in
                    self.signatureImage = savedImage
                    self.saveImageToAlbum(savedImage)
                }
            }
            .onAppear(perform: fetchData)
                      .alert(isPresented: $showAlert) {
                          Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                      }
            .navigationDestination(isPresented: $showContentView) {
                ContentView()
            }
        }
    }

    private func saveImageToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Signature saved to album."
        showAlert = true
    }
}

// SectionView 및 DropdownInfoField 컴포넌트
struct SectionInfoView: View {
    var title: String
    @Binding var text: String
    var showError: Bool = false
    var placeholder: String = ""
    var isRequired: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .opacity(0.7)
                if isRequired { Text("*").foregroundColor(.red) }
            }
            ZStack(alignment: .leading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                // Text 입력 필드
                TextField("", text: $text)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(showError && text.isEmpty ? Color.red : Color.gray, lineWidth: 1)
                    )
            }
        }
    }
}

struct DropdownInfoField: View {
    var title: String
    @Binding var selectedValue: String
    var options: [String]
    var placeholder: String
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
                    Text(selectedValue.isEmpty ? placeholder : selectedValue)
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
