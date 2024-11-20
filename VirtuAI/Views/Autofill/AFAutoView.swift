import SwiftUI
import UIKit
import PDFKit


struct AFAutoView: View {
    let scaleFactor: CGFloat = 1.2
    @State private var zoomScale: CGFloat = 1.0
    @State private var selectedBox: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)?
    @State private var selectedImage: Image? = nil // 선택한 이미지를 저장할 변수
    @State private var isLoading = false
    // AppStorage for Data
    @AppStorage("arcDataSaved") private var savedARCData: Data?
     @AppStorage("passportDataSaved") private var savedPassportData: Data?
     @AppStorage("myInfoDataSaved") private var savedMyInfoData: Data?
   // @AppStorage("myInfoSignatureImage") private var signatureImageData: Data? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    // 텍스트나 체크박스를 수정할 상자들
    @State private var boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
         ("FOREIGN RESIDENT REGISTRATION", 35, 64, 6, 6, ""),
         ("ENGAGE IN ACTIVITIES NOT COVERED BY THE STATUS OF SOJOURN", 35, 80, 6, 6, "✓"),
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
         ("희망 자격 3", 97, 122, 15, 6, ""),
         ("성 Surname", 73, 147, 64, 5, ""),
         ("명 Given names", 146, 147, 74, 5, ""),
         ("년 yyyy", 81, 160, 36, 5, ""),
         ("월 mm", 120, 160, 12, 4, ""),
         ("일 dd", 140, 160, 12, 4, ""),
         ("남 M", 185, 155, 4, 4, ""),
         ("여 F", 185, 158, 4, 4, ""),
         ("국적 Nationality", 252, 160, 24, 21, ""),
         ("외국인 등록 번호 1", 97, 167, 7, 7, ""),
         ("외국인 등록 번호 2", 109, 167, 7, 7, ""),
         ("외국인 등록 번호 3", 118, 167, 7, 7, ""),
         ("외국인 등록 번호 4", 128, 167, 7, 7, ""),
         ("외국인 등록 번호 5", 138, 167, 7, 7, ""),
         ("외국인 등록 번호 6", 148, 167, 7, 7, ""),
         ("외국인 등록 번호 7", 158, 167, 7, 7, ""),
         ("외국인 등록 번호 8", 169, 167, 7, 7, ""),
         ("외국인 등록 번호 9", 176, 167, 7, 7, ""),
         ("외국인 등록 번호 10", 185, 167, 7, 7, ""),
         ("외국인 등록 번호 11", 194, 167, 7, 7, ""),
         ("외국인 등록 번호 12", 203, 167, 7, 7, ""),
         ("외국인 등록 번호 13", 211, 167, 7, 7, ""),
         ("여권 번호 Passport No.", 91, 180, 55, 9, ""),
         ("여권 발급 일자 Passport Issue Date", 170, 178, 45, 8, ""),
         ("여권 유효 기간 Passport Expiry Date", 255, 178, 55, 8, ""),
         ("대한민국 내 주소", 97, 190, 243, 9, ""),
         ("전화번호", 115, 198, 56, 6, ""),
         ("휴대전화", 240, 198, 56, 6, ""),
         ("본국 주소", 150, 206, 166, 9, ""),
         ("전화번호1", 255, 206, 50, 6, ""),
         ("미취학", 82, 215, 4, 4, ""),
         ("초", 108, 215, 4, 4, ""),
         ("중", 125, 215, 4, 4, ""),
         ("고", 140, 215, 4, 4, ""),
         ("학교이름", 190, 215, 56, 9, ""),
         ("전화번호2", 255, 215, 50, 9, ""),
         ("교욱청인가", 187, 225, 4, 4, ""),
         ("교육청비인가", 254, 225, 4, 4, ""),
         ("원 근무처", 115, 240, 24, 8, ""),
         ("사업자 등록 번호1", 191, 240, 29, 8, ""),
         ("전화 번호3", 252, 240, 56, 8, ""),
         ("예정 근무처", 116, 250, 24, 8, ""),
         ("전화 번호4", 252, 250, 56, 8, ""),
         ("연소득금액", 115, 257, 22, 5, ""),
         ("직업", 253, 257, 27, 5, ""),
         ("email", 209, 265, 88, 5, ""),
         ("반환용계좌번호", 221, 274, 91, 9, ""),
         ("신청일", 130, 283, 42, 6, ""),
         ("Signature Box1", 234, 284, 36, 18, ""),
         ("Signature Box2", 64, 343, 36, 18, "")
     ]
    @State private var showAlertForFileName = false
    @State private var showFileTypeSelection = false
    @State private var fileName = ""
    @State private var fileType: String = ""
    @State private var navigateToAFInfoView = false
    @State private var selectedFileTypes: [String] = ["pdf"]
    @State private var selectedFileType: String = "pdf" // Change to single String
    @State private var showShareSheet = false
    @State private var fileURL: URL? // URL to share the generated file
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
//                
//                Spacer()
//                Text("You should edit or delete the red texts \nbefore submitting")
//                    .font(.system(size: 14))
//                    .multilineTextAlignment(.leading) // 텍스트는 왼쪽 정렬
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .multilineTextAlignment(.center) // 여러 줄을 가운데 정렬
//                    .foregroundColor(.red)
//                    .padding(12) // 프레임에 12씩 패딩 추가
//                    .background(Color.red.opacity(0.1))
//                    .cornerRadius(8)
//
//                Spacer()
                // if isLoading {
                // LoadingAlertView()
                GeometryReader { geometry in
                    let canvasWidth: CGFloat = 298 * scaleFactor
                    let canvasHeight: CGFloat = 422 * scaleFactor
                    
                    ZStack {
                        VStack(alignment: .center, spacing: 0) {

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
                            }
                            
                            if let selectedBox = selectedBox {
                                ZoomedBoxView(box: selectedBox, selectedImage: $selectedImage) { newText in
                                    if let index = boxes.firstIndex(where: { $0.title == selectedBox.title }) {
                                        boxes[index].text = newText
                                    }
                                    self.selectedBox = nil
                                }
                            }
                        }
                    }
                    .frame(width: canvasWidth, height: canvasHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }.frame(height: 422 * scaleFactor)
                
                
                
                Spacer()
                
                // Bottom buttons
                HStack {
                    NavigationLink(destination: AFInfoView(), isActive: $navigateToAFInfoView) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        navigateToAFInfoView = true
                    }) {
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
        }
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
        .background(Color.white)
        .onAppear(perform: loadSavedData)
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
    // Load saved data
    private func loadSavedData() {
        if let arcData = savedARCData, let arcDict = try? JSONDecoder().decode([String: String].self, from: arcData) {
            if let foreignRegistrationNumber = arcDict["foreignRegistrationNumber"] {
                for (index, char) in foreignRegistrationNumber.enumerated() {
                    let boxKey = "외국인 등록 번호 \(index + 1)"
                    boxes.updateText(for: boxKey, with: String(char))
                }
            }
        }

        if let passportData = savedPassportData, let passportDict = try? JSONDecoder().decode([String: String].self, from: passportData) {
            boxes.updateText(for: "성 Surname", with: passportDict["surName"] ?? "")
            boxes.updateText(for: "명 Given names", with: passportDict["givenName"] ?? "")
            boxes.updateText(for: "국적 Nationality", with: passportDict["nationality"] ?? "")
            boxes.updateText(for: "여권 번호 Passport No.", with: passportDict["documentNumber"] ?? "")
            boxes.updateText(for: "여권 발급 일자 Passport Issue Date", with: passportDict["dateOfIssue"] ?? "")
            boxes.updateText(for: "여권 유효 기간 Passport Expiry Date", with: passportDict["dateOfExpiry"] ?? "")
        }

        if let myInfoData = savedMyInfoData, let myInfoDict = try? JSONDecoder().decode([String: String].self, from: myInfoData) {
            boxes.updateText(for: "대한민국 내 주소", with: myInfoDict["koreaAddress"] ?? "")
            boxes.updateText(for: "전화번호", with: myInfoDict["telephoneNumber"] ?? "")
            boxes.updateText(for: "휴대전화", with: myInfoDict["phoneNumber"] ?? "")
            boxes.updateText(for: "본국 주소", with: myInfoDict["homelandAddress"] ?? "")
            boxes.updateText(for: "전화번호1", with: myInfoDict["homelandPhoneNumber"] ?? "")
            boxes.updateText(for: "학교이름", with: myInfoDict["schoolName"] ?? "")
            boxes.updateText(for: "전화번호2", with: myInfoDict["schoolPhoneNumber"] ?? "")
            boxes.updateText(for: "원 근무처", with: myInfoDict["originalWorkplaceName"] ?? "")
            boxes.updateText(for: "사업자 등록 번호1", with: myInfoDict["originalWorkplaceRegistrationNumber"] ?? "")
            boxes.updateText(for: "전화 번호3", with: myInfoDict["originalWorkplacePhoneNumber"] ?? "")
            boxes.updateText(for: "예정 근무처", with: myInfoDict["futureWorkplaceName"] ?? "")
            boxes.updateText(for: "전화 번호4", with: myInfoDict["futureWorkplacePhoneNumber"] ?? "")
            boxes.updateText(for: "연소득금액", with: myInfoDict["incomeAmount"] ?? "")
            boxes.updateText(for: "직업", with: myInfoDict["job"] ?? "")
            boxes.updateText(for: "email", with: myInfoDict["email"] ?? "")
            boxes.updateText(for: "반환용계좌번호", with: myInfoDict["refundAccountNumber"] ?? "")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        boxes.updateText(for: "신청일", with: formatter.string(from: Date()))
    }
    // Handle selection logic
    private func handleBoxSelection(at index: Int) {
        // Clear all top category selections first
        if boxes[index].title == "EXTENSION OF SOJOURN PERIOD" ||
            boxes[index].title == "REENTRY PERMIT (SINGLE, MULTIPLE)" ||
            boxes[index].title == "CHANGE OF STATUS OF SOJOURN" {

            for i in boxes.indices {
                if ["EXTENSION OF SOJOURN PERIOD", "REENTRY PERMIT (SINGLE, MULTIPLE)", "CHANGE OF STATUS OF SOJOURN"].contains(boxes[i].title) {
                    boxes[i].text = ""
                }
            }

            // Select the clicked box
            boxes[index].text = "✓"

            // Update corresponding 희망 자격 fields
            updateHopeQualification(for: boxes[index].title)
        }
    }

    // Update "희망 자격" fields
    private func updateHopeQualification(for selectedTitle: String) {
        // Clear all 희망 자격 fields
        for i in boxes.indices {
            if ["희망 자격 1", "희망 자격 2", "희망 자격 3"].contains(boxes[i].title) {
                boxes[i].text = ""
            }
        }

        // Set the corresponding 희망 자격 field
        switch selectedTitle {
        case "EXTENSION OF SOJOURN PERIOD":
            boxes.updateText(for: "희망 자격 1", with: "D-2")
        case "REENTRY PERMIT (SINGLE, MULTIPLE)":
            boxes.updateText(for: "희망 자격 2", with: "D-2")
        case "CHANGE OF STATUS OF SOJOURN":
            boxes.updateText(for: "희망 자격 3", with: "D-2")
        default:
            break
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
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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
// Extension to update text
extension Array where Element == (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String) {
    mutating func updateText(for title: String, with text: String) {
        if let index = firstIndex(where: { $0.title == title }) {
            self[index].text = text
        }
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

