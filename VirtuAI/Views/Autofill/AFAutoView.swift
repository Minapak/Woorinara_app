import SwiftUI
import UIKit
import PDFKit

struct AFAutoView: View {
    let scaleFactor: CGFloat = 1.2
    @State private var zoomScale: CGFloat = 1.0
    @State private var selectedBox: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)?
    @State private var selectedImage: Image? = nil
    @State private var isLoading = false
    @State private var showAlertForFileName = false
    @State private var showFileTypeSelection = false
    @State private var fileName = ""
    @State private var fileType: String = ""
    @State private var navigateToMyInfoView = false
    @State private var selectedFileTypes: [String] = ["pdf"]
    @State private var selectedFileType: String = "pdf"
    @State private var showShareSheet = false
    @State private var fileURL: URL?
    @State private var signatureImage1: UIImage?
    @State private var signatureImage2: UIImage?
    @State private var dataUpdated: Bool = false  // Changed to @State
    @State var selectedIndex = 0
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appChatState: AppChatState
    @Environment(\.presentationMode) var presentationMode
    
    // API Endpoints
    private static let baseARC = "http://43.203.237.202:18080/api/v1/idcard/update"
    private static let basePass = "http://43.203.237.202:18080/api/v1/passport/update"
    private static let baseMyInfo = "http://43.203.237.202:18080/api/v1/members/details/update"
    // AppStorage for Data
    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false
    @AppStorage("myInfoSaved") private var myInfoSaved: Bool = false
    // AppStorage
    @AppStorage("SavedarcData") private var savedARCData: Data?
    @AppStorage("SavedpassportData") private var savedPassportData: Data?
    @AppStorage("SavedmyInfoData") private var savedMyInfoData: Data?
    var arcData: ARCData?
    var passData: PassportData?
    var myInfoDict: [String: String]?
    // API 엔드포인트
    private let endpoint = "http://43.203.237.202:18080/api/v1/members/applicationForm"

       @State private var boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
           ("FOREIGN RESIDENT REGISTRATION", 35, 64, 6, 6, ""),
           ("ENGAGE IN ACTIVITIES NOT COVERED BY THE STATUS OF SOJOURN", 35, 80, 6, 6, ""),
           ("REISSUANCE OF REGISTRATION CARD", 35, 93, 6, 6, ""),
           ("CHANGE OR ADDITION OF WORKPLACE", 35, 103, 6, 6, ""),
           ("EXTENSION OF SOJOURN PERIOD", 35, 121, 6, 6, ""),
           ("REENTRY PERMIT (SINGLE, MULTIPLE)", 113, 65, 6, 6, ""),
           ("CHANGE OF STATUS OF SOJOURN", 113, 82, 6, 6, ""),
           ("ALTERATION OF RESIDENCE", 113, 93, 6, 6, ""),
           ("GRANTING STATUS OF SOJOURN", 113, 104, 6, 6, ""),
           ("CHANGE OF INFORMATION ON REGISTRATION", 113, 121, 6, 6, ""),
           ("희망 자격 1", 187, 65, 15, 6, ""),
           ("희망 자격 2", 97, 104, 15, 6, ""),
           ("희망 자격 3", 97, 122, 15, 6,""),
           ("성 Surname", 73, 147, 64, 5, "YUKI"),
           ("명 Given names", 146, 147, 74, 5, "TANAKA"),
           ("년 yyyy", 81, 160, 36, 5, "1987"),
           ("월 mm", 120, 160, 12, 4, "02"),
           ("일 dd", 140, 160, 12, 4, "01"),
           ("남 M", 185, 155, 4, 4, "✓"),
           ("여 F", 185, 158, 4, 4, ""),
           ("국적 Nationality", 252, 160, 24, 21, "JAPAN"),
           ("외국인 등록 번호 1", 97, 167, 7, 7, "J"),
           ("외국인 등록 번호 2", 109, 167, 7, 7, "1"),
           ("외국인 등록 번호 3", 118, 167, 7, 7, "2"),
           ("외국인 등록 번호 4", 128, 167, 7, 7, "3"),
           ("외국인 등록 번호 5", 138, 167, 7, 7, "7"),
           ("외국인 등록 번호 6", 148, 167, 7, 7, "5"),
           ("외국인 등록 번호 7", 158, 167, 7, 7, "4"),
           ("외국인 등록 번호 8", 169, 167, 7, 7, "6"),
           ("외국인 등록 번호 9", 176, 167, 7, 7, "7"),
           ("외국인 등록 번호 10", 185, 167, 7, 7, "8"),
           ("외국인 등록 번호 11", 194, 167, 7, 7, "9"),
           ("외국인 등록 번호 12", 203, 167, 7, 7, "0"),
           ("외국인 등록 번호 13", 211, 167, 7, 7, "0"),
           ("여권 번호 Passport No.", 91, 180, 55, 9, "J12345678"),
           ("여권 발급 일자 Passport Issue Date", 170, 178, 45, 8, "20290402"),
           ("여권 유효 기간 Passport Expiry Date", 255, 178, 55, 8, "20290402"),
           ("대한민국 내 주소", 97, 190, 243, 9, "서울시 성북구 고려대로10길 39"),
           ("전화번호", 115, 198, 56, 6, "02-1234-5677"),
           ("휴대전화", 240, 198, 56, 6, "010-1234-5677"),
           ("본국 주소", 150, 206, 166, 9, "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923"),
           ("전화번호1", 255, 206, 50, 6, "016-1234-5677"),
           ("미취학", 82, 215, 4, 4, "✓"),
           ("초", 108, 215, 4, 4, "✓"),
           ("중", 125, 215, 4, 4, "✓"),
           ("고", 140, 215, 4, 4, "✓"),
           ("학교이름", 190, 215, 56, 9, "Fafa school"),
           ("전화번호2", 255, 215, 50, 9, "016-7734-5677"),
           ("교욱청인가", 187, 225, 4, 4, "✓"),
           ("교육청비인가", 254, 225, 4, 4, "✓"),
           ("원 근무처", 115, 240, 24, 8, "Fafa Inc"),
           ("사업자 등록 번호1", 191, 240, 29, 8, "12345678"),
           ("전화 번호3", 252, 240, 56, 8, "016-7734-5677"),
           ("예정 근무처", 116, 250, 24, 8, "Fafa Inc"),
           ("사업자 등록 번호2", 191, 250, 29, 8, "12345678"),
           ("전화 번호4", 252, 250, 56, 8, "016-7734-5677"),
           ("연소득금액", 115, 257, 22, 5, "5000"),
           ("직업", 253, 257, 27, 5, "student"),
           ("재입국신청기간", 117, 265, 29, 8, "20301212"),
           ("email", 209, 265, 88, 5, "zypher.kr@gmail.com"),
           ("반환용계좌번호", 221, 274, 91, 9, "KOOKMIN, 123456-12-234456"),
           ("신청일", 130, 283, 42, 6, "20301212"),
           ("Signature Box1", 234, 284, 36, 18, ""),
           ("Signature Box2", 64, 343, 36, 18, "")
       ]
       
       var body: some View {
           NavigationStack {
               
               VStack(spacing: 0) {
                   Spacer()
                   Text("You should edit or delete the red texts before submitting")
                       .font(.system(size: 12))
                       .multilineTextAlignment(.leading) // 텍스트는 왼쪽 정렬
                       .frame(maxWidth: .infinity, alignment: .center)
                       .multilineTextAlignment(.center) // 여러 줄을 가운데 정렬
                       .foregroundColor(.red)
                       .padding(5) // 프레임에 12씩 패딩 추가
                       .background(Color.red.opacity(0.1))
                       .cornerRadius(8)
                   
                   Spacer()
                   GeometryReader { geometry in
                       let canvasWidth: CGFloat = 298 * scaleFactor
                       let canvasHeight: CGFloat = 422 * scaleFactor
                       
                       ZStack {
                           Image("af_high")
                               .resizable()
                               .scaledToFit()
                               .frame(width: canvasWidth, height: canvasHeight)
                               .offset(y: -20)
                               .scaleEffect(zoomScale)
                           
                           ForEach(boxes.indices, id: \.self) { index in
                               BoxAutoView(
                                title: boxes[index].title,
                                width: boxes[index].width * scaleFactor,
                                height: boxes[index].height * scaleFactor,
                                xPosition: boxes[index].x * scaleFactor,
                                yPosition: boxes[index].y * scaleFactor - 10,
                                text: boxes[index].text,
                                selectedImage: getSignatureImage(for: boxes[index].title),
                                isSelected: selectedBox?.title == boxes[index].title,
                                onSelect: {
                                    selectedBox = boxes[index]
                                }
                               )
                           }
                       }
                       .frame(width: canvasWidth, height: canvasHeight)
                       .position(x: geometry.size.width / 1.9, y: geometry.size.height / 1.9)
                   }
                   .frame(height: 422 * scaleFactor)
                   
                   if isLoading {
                       LoadingAlertView()
                   }
                   
                   Spacer()
                   
                   // Bottom buttons
                   HStack {
                       NavigationLink(destination: AFInfoView()) {
                           Text("Edit")
                               .font(.headline)
                               .frame(maxWidth: .infinity)
                               .padding()
                               .background(Color.blue.opacity(0.2))
                               .foregroundColor(.blue)
                               .cornerRadius(10)
                       }
                       
                       Button(action: {
                           showAlertForFileName = true
                       }) {
                           Text("Save")
                               .font(.headline)
                               .frame(maxWidth: .infinity)
                               .padding()
                               .background(Color.blue)
                               .foregroundColor(.white)
                               .cornerRadius(10)
                       }
                   }
                   .padding(.horizontal)
                   .padding(.bottom, 20)
               }
               .navigationBarBackButtonHidden(true)
               .navigationBarItems(leading: Button(action: {
                   presentationMode.wrappedValue.dismiss()
               }) {
                   Image(systemName: "chevron.left")
                       .foregroundColor(.black)
               })
               .background(Color.white)
               .onAppear {
                   loadSavedData()
                   loadSignatureImages()
               }
               .alert("Save as...", isPresented: $showAlertForFileName) {
                   VStack {
                       TextField("Enter file name", text: $fileName)
                           .padding()
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(8)
                       
                       Button("Save") {
                           showFileTypeSelection = true
                       }
                       .padding(.top, 10)
                       .frame(maxWidth: .infinity)
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
                   }
                   .padding()
               }
               .actionSheet(isPresented: $showFileTypeSelection) {
                   ActionSheet(
                    title: Text("Save file"),
                    message: Text("Choose file format"),
                    buttons: [
                        .default(Text("PDF"), action: { saveFile(as: "pdf") }),
                        .default(Text("PNG"), action: { saveFile(as: "png") }),
                        .cancel()
                    ]
                   )
               }
               .sheet(isPresented: $showShareSheet, content: {
                   if let fileURL = fileURL {
                       ShareSheet(activityItems: [fileURL])
                   }
               })
               
           }
       }
    
    private func saveFile(as fileType: String) {
        self.selectedFileType = fileType
        // Generate the file based on the selected file type
        if fileType == "pdf" {
            createPDF()
        } else if fileType == "png" {
            createPNG()
        }
    }
    private func toggleFileType(_ fileType: String) {
        if selectedFileTypes.contains(fileType) {
            selectedFileTypes.removeAll { $0 == fileType }
        } else {
            selectedFileTypes.append(fileType)
        }
    }
    private func createPDF() {
        isLoading = true // 로딩 시작
        let pdfURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        let pageSize = CGRect(x: 0, y: 0, width: 298 * scaleFactor, height: 422 * scaleFactor)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        do {
            try pdfRenderer.writePDF(to: pdfURL) { context in
                context.beginPage()
                
                if let snapshotImage = snapshotViewAsImage() {
                    snapshotImage.draw(in: pageSize)
                }
            }
            
            self.fileURL = pdfURL
            self.showShareSheet = true
            self.isLoading = false // 로딩 종료
        } catch {
            print("Could not create PDF file: \(error)")
            self.isLoading = false // 로딩 종료
        }
    }

    private func createPNG() {
        isLoading = true // 로딩 시작
        let pngURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).png")
        
        if let snapshotImage = snapshotViewAsImage() {
            if let pngData = snapshotImage.pngData() {
                do {
                    try pngData.write(to: pngURL)
                    self.fileURL = pngURL
                    self.showShareSheet = true
                    self.isLoading = false // 로딩 종료
                } catch {
                    print("Could not create PNG file: \(error)")
                    self.isLoading = false // 로딩 종료
                }
            } else {
                print("Failed to generate PNG data.")
                self.isLoading = false // 로딩 종료
            }
        }
    }
    
    private func loadSavedData() {
        // ARC Data
             if let arcData = savedARCData,
                let arcResult = try? JSONDecoder().decode(ARCResult.self, from: arcData) {
                 updateBoxesWithARCData(arcResult.data)
             }
             
             // Passport Data
             if let passData = savedPassportData,
                let passResult = try? JSONDecoder().decode(PassportResult.self, from: passData) {
                 updateBoxesWithPassportData(passResult.data)
             }
             
             // MyInfo Data
             if let myInfoData = savedMyInfoData,
                let myInfoDict = try? JSONDecoder().decode([String: String].self, from: myInfoData) {
                 updateBoxesWithMyInfoData(myInfoDict)
             }
        
        if dataUpdated {
            if let arcData = self.arcData {
                updateBoxesWithARCData(arcData)
            }
            if let passData = self.passData {
                updateBoxesWithPassportData(passData)
            }
            if let myInfoDict = self.myInfoDict {
                updateBoxesWithMyInfoData(myInfoDict)
            }
            dataUpdated = false
        }
    }
    
     
     private func loadSignatureImages() {
         if let myInfoData = savedMyInfoData,
            let myInfoDict = try? JSONDecoder().decode([String: String].self, from: myInfoData) {
             if let signatureUrl = myInfoDict["signatureUrl"],
                let url = URL(string: signatureUrl) {
                 loadSignatureImage(from: url) { image in
                     signatureImage1 = image
                     signatureImage2 = image
                     updateSignatureBoxes()
                 }
             }
         }
     }
     
     private func loadSignatureImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
         URLSession.shared.dataTask(with: url) { data, response, error in
             if let data = data, let image = UIImage(data: data) {
                 DispatchQueue.main.async {
                     completion(image)
                 }
             } else {
                 DispatchQueue.main.async {
                     completion(nil)
                 }
             }
         }.resume()
     }
     
     private func updateSignatureBoxes() {
         boxes = boxes.map { box in
             if box.title == "Signature Box1" || box.title == "Signature Box2" {
                 var newBox = box
                 if let myInfoData = savedMyInfoData,
                    let myInfoDict = try? JSONDecoder().decode([String: String].self, from: myInfoData),
                    let signatureUrl = myInfoDict["signatureUrl"] {
                     newBox.text = signatureUrl
                 }
                 return newBox
             }
             return box
         }
     }
     
     private func getSignatureImage(for boxTitle: String) -> Image? {
         if boxTitle == "Signature Box1" || boxTitle == "Signature Box2" {
             if let signatureImage = signatureImage1 {
                 return Image(uiImage: signatureImage)
             }
         }
         return nil
     }
    private func updateBoxesWithARCData(_ data: ARCData?) {
        guard let data = data else { return }
        boxes = boxes.map { box in
            var newBox = box
            switch box.title {
            case "외국인 등록 번호 1", "외국인 등록 번호 2", "외국인 등록 번호 3",
                 "외국인 등록 번호 4", "외국인 등록 번호 5", "외국인 등록 번호 6",
                 "외국인 등록 번호 7", "외국인 등록 번호 8", "외국인 등록 번호 9",
                 "외국인 등록 번호 10", "외국인 등록 번호 11", "외국인 등록 번호 12",
                 "외국인 등록 번호 13":
                let index = Int(box.title.split(separator: " ").last!)! - 1
                if let regNum = data.foreignRegistrationNumber,
                   index < regNum.count {
                    let strIndex = regNum.index(regNum.startIndex, offsetBy: index)
                    newBox.text = String(regNum[strIndex])
                }
            default:
                break
            }
            return newBox
        }
    }
        

    private func updateBoxesWithPassportData(_ data: PassportData?) {
        guard let data = data else { return }
        boxes = boxes.map { box in
            var newBox = box
            switch box.title {
            case "성 Surname":
                newBox.text = data.surName ?? ""
            case "명 Given names":
                newBox.text = data.givenName ?? ""
            case "여권 번호 Passport No.":
                newBox.text = data.documentNumber ?? ""
            case "여권 발급 일자 Passport Issue Date":
                newBox.text = data.dateOfIssue ?? ""
            case "여권 유효 기간 Passport Expiry Date":
                newBox.text = data.dateOfExpiry ?? ""
            case "국적 Nationality":
                newBox.text = data.nationality ?? ""
            case "년 yyyy":
                newBox.text = String(data.dateOfBirth?.prefix(4) ?? "")
            case "월 mm":
                if let birthDate = data.dateOfBirth {
                    let start = birthDate.index(birthDate.startIndex, offsetBy: 4)
                    let end = birthDate.index(start, offsetBy: 2)
                    newBox.text = String(birthDate[start..<end])
                }
            case "일 dd":
                newBox.text = String(data.dateOfBirth?.suffix(2) ?? "")
            case "남 M":
                newBox.text = data.gender == "M" ? "✓" : ""
            case "여 F":
                newBox.text = data.gender == "F" ? "✓" : ""
            default:
                break
            }
            return newBox
        }
    }

        
    private func updateBoxesWithMyInfoData(_ data: [String: String]) {
        boxes = boxes.map { box in
            var newBox = box
            switch box.title {
            case "대한민국 내 주소":
                newBox.text = data["koreaAddress"] ?? ""
            case "전화번호":
                newBox.text = data["telephoneNumber"] ?? ""
            case "휴대전화":
                newBox.text = data["phoneNumber"] ?? ""
            case "본국 주소":
                newBox.text = data["homelandAddress"] ?? ""
            case "전화번호1":
                newBox.text = data["homelandPhoneNumber"] ?? ""
            case "미취학":
                newBox.text = data["schoolStatus"] == "NonSchool" ? "✓" : ""
            case "초":
                newBox.text = data["schoolStatus"] == "Elementary" ? "✓" : ""
            case "중":
                newBox.text = data["schoolStatus"] == "Middle" ? "✓" : ""
            case "고":
                newBox.text = data["schoolStatus"] == "High" ? "✓" : ""
            case "학교이름":
                newBox.text = data["schoolName"] ?? ""
            case "전화번호2":
                newBox.text = data["schoolPhoneNumber"] ?? ""
            case "교욱청인가":
                newBox.text = data["schoolType"] == "Accredited" ? "✓" : ""
            case "교육청비인가":
                newBox.text = data["schoolType"] == "NonAccredited" ? "✓" : ""
            case "원 근무처":
                newBox.text = data["originalWorkplaceName"] ?? ""
            case "사업자 등록 번호1":
                newBox.text = data["originalWorkplaceRegistrationNumber"] ?? ""
            case "전화 번호3":
                newBox.text = data["originalWorkplacePhoneNumber"] ?? ""
            case "예정 근무처":
                newBox.text = data["futureWorkplaceName"] ?? ""
            case "사업자 등록 번호2":
                newBox.text = data["futureWorkplaceRegistrationNumber"] ?? ""
            case "전화 번호4":
                newBox.text = data["futureWorkplacePhoneNumber"] ?? ""
            case "연소득금액":
                newBox.text = data["incomeAmount"] ?? ""
            case "직업":
                newBox.text = data["job"] ?? ""
            case "반환용계좌번호":
                newBox.text = data["refundAccountNumber"] ?? ""
            default:
                break
            }
            return newBox
        }
    }
        
    private func snapshotViewAsImage() -> UIImage? {
        DispatchQueue.main.async {
               self.isLoading = true // 로딩 시작
           }
           
        // 1. UIHostingController를 사용하여 SwiftUI 뷰를 UIKit 뷰로 변환합니다.
        let hostingController = UIHostingController(rootView:
            GeometryReader { geometry in
                let canvasWidth: CGFloat = 298 * scaleFactor
                let canvasHeight: CGFloat = 422 * scaleFactor
                
                ZStack {
                    Image("af_high")
                        .resizable()
                        .scaledToFit()
                        .frame(width: canvasWidth, height: canvasHeight)
                        .offset(y: -30)
                        .scaleEffect(zoomScale)
                    
                    ForEach(boxes.indices, id: \.self) { index in
                        BoxAutoView(
                            title: boxes[index].title,
                            width: boxes[index].width * scaleFactor,
                            height: boxes[index].height * scaleFactor,
                            xPosition: boxes[index].x * scaleFactor,
                            yPosition: boxes[index].y * scaleFactor - 20,
                            text: boxes[index].text,
                            selectedImage: selectedImage,
                            isSelected: selectedBox?.title == boxes[index].title,
                            onSelect: {
                                selectedBox = boxes[index]
                            }
                        )
                        .foregroundColor(.black) // 텍스트와 체크표시를 검정색으로 설정
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
                .position(x: geometry.size.width / 1.9, y: geometry.size.height / 1.9)
            }
        )
        
        let targetSize = CGSize(width: 298 * scaleFactor, height: 422 * scaleFactor)
        
        hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
        hostingController.view.backgroundColor = .white // 배경을 흰색으로 설정
        
        // 2. UIView를 UIImage로 렌더링합니다.
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        DispatchQueue.main.async {
              self.isLoading = false // 로딩 종료
          }
        
        return image
    }

}
struct LoadingAlertView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 10) {
                Image("loadingCircle") // 로딩 이미지를 넣어주세요
                    .resizable()
                    .frame(width: 26, height: 8)
                Text("It may take 1 ~ 2 minutes.")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}
    struct BoxAutoView: View {
        var title: String
        var width: CGFloat
        var height: CGFloat
        var xPosition: CGFloat
        var yPosition: CGFloat
        var text: String
        var selectedImage: Image? // 서명 박스에 표시할 이미지
        var isSelected: Bool
        var onSelect: () -> Void
        
        var body: some View {
            ZStack {
                if (xPosition == 234 && yPosition == 284 && width == 36 && height == 18) ||
                    (xPosition == 64 && yPosition == 343 && width == 36 && height == 18) {
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: width, height: height)
                    } else {
                        Rectangle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: width, height: height)
                            .overlay(
                                Image("sign")
                                    .resizable()
                                    .scaledToFit()
                            )
                    }
                } else if text == "✓" {
                    // 체크박스 표현
                    Rectangle()
                        .fill(isSelected ? Color.green.opacity(0.3) : Color.clear)
                        .frame(width: width, height: height)
                        .overlay(
                            Text(text)
                                .font(.system(size: 5, weight: .bold))
                                .foregroundColor(.blue)
                        )
                } else {
                    Text(text)
                        .font(.system(size: 5, weight: .bold))
                        .foregroundColor(.blue)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(width: width, height: height)
                }
            }
            .position(x: xPosition, y: yPosition)
            .onTapGesture {
                onSelect()
            }
        }
    }
    
    struct ZoomedBoxView: View {
        @State private var boxText: String
        var box: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)
        @Binding var selectedImage: Image?
        var onClose: (String) -> Void
        @State private var isImagePickerPresented = false
        
        init(box: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String), selectedImage: Binding<Image?>, onClose: @escaping (String) -> Void) {
            self.box = box
            self._boxText = State(initialValue: box.text)
            self._selectedImage = selectedImage
            self.onClose = onClose
        }
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { onClose(boxText) }) {
                        Text("닫기")
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                Spacer()
                
                if let selectedImage = selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    TextField("Edit Text", text: $boxText)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                
                
                
                Spacer()
            }
            .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: Image?
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            init(_ parent: ImagePicker) { self.parent = parent }
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.selectedImage = Image(uiImage: uiImage)
                }
                picker.dismiss(animated: true)
            }
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
