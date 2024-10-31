//
//  PDFClickView.swift
//  VirtuAI
//
//  Created by 박은민 on 10/23/24.
//

import SwiftUI
import PDFKit

struct PDFClickViewer: View {
    @State private var document: PDFDocument?
    @State private var showModal = false // State to control modal presentation

    var body: some View {
        VStack {
            Spacer()
            PDFModalViewRepresentable(document: document)
                .frame(width: 350, height: 490)  // 프레임 사이즈 설정
                .background(Color.gray.opacity(0.3))  // 배경색 설정으로 시각적 확인 용이
                .cornerRadius(8)  // 모서리 둥글게 처리
                .padding()
                .onTapGesture { // Tap gesture to show the modal
                    showModal.toggle()
                }
            Spacer()
        }
        .onAppear {
            loadPDF()
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showModal) {
            ModalView1() // Show the modal when tapped
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
struct ModalView1: View {
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
    
    @Environment(\.dismiss) var dismiss
    
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
                        .buttonStyle(PlainButtonStyle()) // To remove button styling
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: {
                // Handle submit action here
                dismiss() // Close the modal
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


// PDF view representation
struct PDFModalViewRepresentable: UIViewRepresentable {
    var document: PDFDocument?

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = document
        pdfView.autoScales = true  // PDF 내용이 프레임에 맞도록 자동 조정
        return pdfView
    }

    func updateUIView(_ pdfView: PDFKit.PDFView, context: Context) {
        pdfView.document = document
    }
}

struct PdfContentModalView: View {
    var body: some View {
        PDFClickViewer()
    }
}

struct PDFEditorClickApp: App {
    var body: some Scene {
        WindowGroup {
            PdfContentModalView()
        }
    }
}
