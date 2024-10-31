import SwiftUI
import PDFKit

struct PDFViewer: View {
    @State private var document: PDFDocument?
    @State private var imageSize: CGSize = .zero
    @State private var showTranslationView = false
    @State private var showAutoFillView = false
    @State private var checkBoxStates: [Bool] = Array(repeating: false, count: 10)
    @State private var showModal = false

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
    
    @State private var selectedLanguage: String? = nil
    @State private var isLanguageDropdownOpen = false
    @State private var selectedImage = "af"
    
    var languageOptions = ["English", "Vietnamese", "Chinese", "Japanese"]
    var imageOptions = ["af_e", "af_v", "af_c", "af_j"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 10) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button("Korean") {
                                showTranslationView = true
                            }
                            .frame(width: 150, height: 50)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .cornerRadius(16)

                            VStack(alignment: .leading) {
                                Button(action: {
                                    isLanguageDropdownOpen.toggle()
                                }) {
                                    HStack {
                                        Text(selectedLanguage ?? "Language")
                                            .foregroundColor(.gray)
                                        Image(systemName: isLanguageDropdownOpen ? "chevron.up" : "chevron.down")
                                    }
                                    .frame(width: 150, height: 50)
                                    .font(.system(size: 16, weight: .bold))
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                }

                                if isLanguageDropdownOpen {
                                    VStack(alignment: .leading) {
                                        ForEach(languageOptions.indices, id: \.self) { index in
                                            Button(action: {
                                                selectedLanguage = languageOptions[index]
                                                selectedImage = imageOptions[index]
                                                isLanguageDropdownOpen = false
                                            }) {
                                                Text(languageOptions[index])
                                                    .foregroundColor(.blue)
                                                    .padding(.vertical, 5)
                                                    .padding(.horizontal, 10)
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Spacer()
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 300)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding()
                    Spacer()

                    HStack {
                        Button("Translation") {
                            showTranslationView = true
                        }
                        .frame(width: 150, height: 50)
                        .font(.system(size: 16, weight: .bold))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)

                        Button("Auto-Fill") {
                            showAutoFillView = true
                        }
                        .frame(width: 150, height: 50)
                        .font(.system(size: 16, weight: .bold))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.bottom, 5)
                .padding(16)
            }
            .background(
                NavigationLink(destination: TranslateView(), isActive: $showTranslationView) { EmptyView() }
            )
            .background(
                NavigationLink(destination: PDFClickViewer(), isActive: $showAutoFillView) { EmptyView() }
            )
        }
    }

    private func loadPDF() {
        guard let uiImage = UIImage(named: selectedImage) else {
            print("Failed to load image from resources.")
            return
        }
        imageSize = uiImage.size

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: uiImage.size.width, height: uiImage.size.height), nil)
        UIGraphicsBeginPDFPage()
        let pdfContext = UIGraphicsGetCurrentContext()

        uiImage.draw(in: CGRect(x: 0, y: 0, width: uiImage.size.width, height: uiImage.size.height), blendMode: .normal, alpha: 1.0)
        drawCheckBoxes(context: pdfContext)
        UIGraphicsEndPDFContext()

        if let document = PDFDocument(data: pdfData as Data) {
            self.document = document
        }
    }

    private func drawCheckBoxes(context: CGContext?) {
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(2)

        for (index, (x, y)) in checkBoxCoordinates.enumerated() {
            let rect = CGRect(x: x, y: y, width: checkBoxSize.width, height: checkBoxSize.height)
            
            if index == 1 || index == 6 {
                context?.setFillColor(UIColor.blue.cgColor)
                context?.fill(rect)
            } else {
                context?.stroke(rect)
            }
        }
    }
}
