import SwiftUI

struct AFAutoView: View {
    let scaleFactor: CGFloat = 1
    @State private var zoomScale: CGFloat = 1.0
    @State private var selectedBox: (title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)?
    @State private var selectedImage: Image? = nil  // 선택한 이미지를 저장할 변수
    
    // 텍스트나 체크박스를 수정할 상자들
    @State private var boxes: [(title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, text: String)] = [
        ("성 Surname", 73, 145, 64, 5, "YUKI"),
            ("명 Given names", 146, 145, 74, 5, "TANAKA"),
            ("년 yyyy", 81, 160, 36, 5, "1987"),
            ("월 mm", 120, 160, 12, 4, "02"),
            ("일 dd", 140, 160, 12, 4, "01"),
            ("남 M", 183, 153, 4, 4, "✓"),
            ("여 F", 183, 158, 4, 4, ""),
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
        GeometryReader { geometry in
            let canvasWidth: CGFloat = 298 * scaleFactor
            let canvasHeight: CGFloat = 422 * scaleFactor

            ZStack {
                Image("af")
                    .resizable()
                    .frame(width: canvasWidth, height: canvasHeight)
                    .offset(y: -30)
                    .edgesIgnoringSafeArea(.all)
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
                            boxes[index].text = newText // 수정된 텍스트 반영
                        }
                        self.selectedBox = nil // 확대 뷰 닫기
                    }
                }
            }
            .frame(width: canvasWidth, height: canvasHeight)
        }
        .frame(width: 298, height: 422)
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
            
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("사진 선택")
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
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
