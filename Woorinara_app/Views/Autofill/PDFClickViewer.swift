import SwiftUI
import PDFKit

struct PDFClickViewer: View {
    @State private var document: PDFDocument?
    @State private var checkBoxStates: [Bool] = Array(repeating: false, count: 10)
    @State private var showModal = false
    @State private var selectedIndex: Int? = nil  // 선택된 체크박스 인덱스

    let checkBoxCoordinates: [(CGFloat, CGFloat)] = [
        (259, 569), (253, 708), (253, 806), (253, 906), (253, 1052),
        (914, 569), (917, 711), (916, 807), (917, 906), (916, 1054)
    ]

    let checkBoxSize = CGSize(width: 49, height: 56)
    let checkBoxTexts = [
        "FOREIGN RESIDENT REGISTRATION",
        "ENGAGE IN ACTIVITIES NOT COVERED BY THE STATUS OF SOJOURN",
        "REISSUANCE OF REGISTRATION CARD",
        "CHANGE OR ADDITION OF WORKPLACE",
        "EXTENSION OF SOJOURN PERIOD",
        "REENTRY PERMIT (SINGLE, MULTIPLE)",
        "CHANGE OF STATUS OF SOJOURN",
        "ALTERATION OF RESIDENCE",
        "GRANTING STATUS OF SOJOURN",
        "CHANGE OF INFORMATION ON REGISTRATION"
    ]

    var body: some View {
        VStack {
            Spacer()
            
            // PDF 컨텐츠를 네모박스에 넣어 표시
            ZStack {
        
        
                PDFModalViewRepresentable_pdf(document: document, checkBoxStates: $checkBoxStates, checkBoxCoordinates: checkBoxCoordinates, checkBoxSize: checkBoxSize) { location in
                    // 특정 영역 내 클릭 시 모달 표시
                    if let index = checkBoxCoordinates.firstIndex(where: { abs($0.0 - location.x) < checkBoxSize.width && abs($0.1 - location.y) < checkBoxSize.height }) {
                        selectedIndex = index
                        showModal.toggle()
                    }
                }
                .frame(width: 350, height: 490)
                .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            loadPDF()
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showModal) {
            ModalView_pdf(selectedIndex: $selectedIndex) { index in
                if let index = index {
                    checkBoxStates[index] = true  // 선택한 항목의 체크박스를 활성화
                }
                showModal = false  // 모달 닫기
            }
        }
    }
    
    private func loadPDF() {
        guard let uiImage = UIImage(named: "af") else {
            print("Failed to load image from resources.")
            return
        }
        print("Image loaded successfully.")
        
        // PDF 문서 생성 및 이미지 추가
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: uiImage.size.width, height: uiImage.size.height), nil)
        UIGraphicsBeginPDFPage()
        let pdfContext = UIGraphicsGetCurrentContext()
        uiImage.draw(in: CGRect(x: 0, y: 0, width: uiImage.size.width, height: uiImage.size.height), blendMode: .normal, alpha: 1.0)
        UIGraphicsEndPDFContext()
        
        if let document = PDFDocument(data: pdfData as Data) {
            print("PDF document created successfully.")
            self.document = document
        } else {
            print("Failed to create PDF document from image data.")
        }
    }
}

// Modal View that gets presented
struct ModalView_pdf: View {
    @Binding var selectedIndex: Int?
    let onSubmit: (Int?) -> Void
    @State private var selectedItems: [Int: Bool] = [:] // Stores the selection states
    
    let items = [
        "FOREIGN RESIDENT REGISTRATION",
        "ENGAGE IN ACTIVITIES NOT COVERED BY THE STATUS OF SOJOURN",
        "REISSUANCE OF REGISTRATION CARD",
        "CHANGE OR ADDITION OF WORKPLACE",
        "EXTENSION OF SOJOURN PERIOD",
        "REENTRY PERMIT (SINGLE, MULTIPLE)",
        "CHANGE OF STATUS OF SOJOURN",
        "ALTERATION OF RESIDENCE",
        "GRANTING STATUS OF SOJOURN",
        "CHANGE OF INFORMATION ON REGISTRATION"
    ]
    
    var body: some View {
        VStack {
            Text("Select Application/Report")
                .font(.headline)
                .padding()
            
            ScrollView {
                ForEach(items.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            // Toggle selection state
                            selectedItems[index, default: false].toggle()
                            selectedIndex = selectedItems[index, default: false] ? index : nil
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: selectedItems[index, default: false] ? "checkmark.circle.fill" : "checkmark.circle")
                                    .foregroundColor(selectedItems[index, default: false] ? .blue : .gray)
                                Text(items[index])
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: {
                onSubmit(selectedIndex)
            }) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.white)
    }
}

// PDF view representation with checkboxes
struct PDFModalViewRepresentable_pdf: UIViewRepresentable {
    var document: PDFDocument?
    @Binding var checkBoxStates: [Bool]
    var checkBoxCoordinates: [(CGFloat, CGFloat)]
    var checkBoxSize: CGSize
    var onTap: ((CGPoint) -> Void)?

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = document
        pdfView.autoScales = true  // PDF 내용이 프레임에 맞도록 자동 조정
        addCheckBoxLayers(to: pdfView)
        
        // PDFKit.PDFView 터치 핸들러 설정
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        pdfView.addGestureRecognizer(tapGesture)
        
        return pdfView
    }

    func updateUIView(_ pdfView: PDFKit.PDFView, context: Context) {
        pdfView.document = document
        addCheckBoxLayers(to: pdfView)
    }
    
    private func addCheckBoxLayers(to pdfView: PDFKit.PDFView) {
        pdfView.layer.sublayers?.removeAll { $0.name == "CheckBoxLayer" }
        
        for (index, coordinate) in checkBoxCoordinates.enumerated() {
            let checkBoxLayer = CALayer()
            checkBoxLayer.frame = CGRect(origin: CGPoint(x: coordinate.0, y: coordinate.1), size: checkBoxSize)
            checkBoxLayer.name = "CheckBoxLayer"
            checkBoxLayer.backgroundColor = checkBoxStates[index] ? UIColor.blue.cgColor : UIColor.clear.cgColor
            checkBoxLayer.borderWidth = 1.5
            checkBoxLayer.borderColor = UIColor.blue.cgColor
            checkBoxLayer.cornerRadius = 5
            pdfView.layer.addSublayer(checkBoxLayer)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
    
    class Coordinator: NSObject {
        var onTap: ((CGPoint) -> Void)?
        
        init(onTap: ((CGPoint) -> Void)?) {
            self.onTap = onTap
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let pdfView = sender.view as? PDFKit.PDFView else { return }
            let location = sender.location(in: pdfView)
            onTap?(location)
        }
    }
}

struct PdfContentModalView_pdf: View {
    var body: some View {
        PDFClickViewer()
    }
}

struct PDFClickApp: App {
    var body: some Scene {
        WindowGroup {
            PdfContentModalView_pdf()
        }
    }
}
