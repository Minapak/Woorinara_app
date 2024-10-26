//
//  ContentVcomView.swift
//  Demo-iOS
//
//  Created by 박은민 on 10/18/24.
//

import SwiftUI
import VComponents
import VCore

struct ContentVcomView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            NavigationLink("내 정보", destination: ContentTFView())
                            NavigationLink("PDF 문서", destination: PDFViewer())
                            NavigationLink("PNG 사진", destination: ImageViewer())
                            NavigationLink("여권 정보 발췌", destination: ContentPView())
                            NavigationLink("정보 텍스트 뷰 전달", destination: ContentPView1())
                            NavigationLink("챗봇", destination: ContentMView())
                            NavigationLink("셋팅", destination: SettingsView())
                        }
                        .navigationTitle("My Page")
                    }
//                    Spacer()
//                    Image("af")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 300)
//                        .background(Color.gray.opacity(0.3))
//                        .cornerRadius(8)
//                        .padding()
                    Spacer()

                    HStack {
//                        // Translation 버튼
//                        Button("Translation") {
//                            showTranslationView = true
//                        }
//                        .frame(width: 150, height: 50) // 버튼 크기 지정
//                        .font(.system(size: 16, weight: .bold))
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(16)
//
//                        // Auto-Fill 버튼
//                        Button("Auto-Fill") {
//                            showAutoFillView = true
//                        }
//                        .frame(width: 150, height: 50) // 버튼 크기 지정
//                        .font(.system(size: 16, weight: .bold))
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(16)
                    }
                }.padding(.bottom, 5)
                .padding(16)
            }
            // NavigationLink를 사용하여 뷰 전환
//            .background(
//                NavigationLink(destination: PDFClickViewer(), isActive: $showTranslationView) { EmptyView() }
//            )
//            .background(
//                NavigationLink(destination: PDFViewer(), isActive: $showAutoFillView) { EmptyView() }
//            )
        }
    }
}



// MARK: Modals Examples
struct ModalsView: View {
    @State private var showModal = false
    
    var body: some View {
        VStack {
            Button("Show Modal") {
                showModal.toggle()
            }
            .sheet(isPresented: $showModal) {
                VStack {
                    Text("Modal Content")
                    Button("Close", action: { showModal = false })
                }
            }
        }
        .padding()
        .navigationTitle("Modals")
    }
}

// MARK: VContinuousSpinner Example
struct IndicatorsView: View {
    var body: some View {
        VContinuousSpinner()
            .padding()
            .navigationTitle("VContinuousSpinner")
    }
}

// MARK: Notifications Examples



struct ContentVcomView_Previews: PreviewProvider {
    static var previews: some View {
        ContentVcomView()
    }
}

