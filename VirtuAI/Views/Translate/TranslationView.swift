import SwiftUI

struct TranslationView: View {
    // 화면 이동을 위한 상태 변수
    @State private var showTranslationView = false
    @State private var showAutoFillView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 10) {
                    AppBar(title: "", isMainPage: true)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Fill out your Application Form")
                            .font(.system(size: 24).bold())
                            .foregroundColor(.black)
                        Text("easy and quick!")
                            .font(.system(size: 24).bold())
                            .foregroundColor(.black)
                        Spacer()
                        Text("With just one click,")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("you can translate and auto-fill your Application Form.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image("af")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 300)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding()
                    Spacer()

                    HStack {
                        // Translation 버튼
                        Button("Translation") {
                            showTranslationView = true
                        }
                        .frame(width: 150, height: 50) // 버튼 크기 지정
                        .font(.system(size: 16, weight: .bold))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)

                        // Auto-Fill 버튼
                        Button("Auto-Fill") {
                            showAutoFillView = true
                        }
                        .frame(width: 150, height: 50) // 버튼 크기 지정
                        .font(.system(size: 16, weight: .bold))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }.padding(.bottom, 5)
                .padding(16)
            }
            // NavigationLink를 사용하여 뷰 전환
            .background(
                NavigationLink(destination: TranslateView(), isActive: $showTranslationView) { EmptyView() }
            )
            .background(
                NavigationLink(destination: AFTransView(), isActive: $showAutoFillView) { EmptyView() }
            )
        }
    }
}



struct ContentImageView: View {
    var body: some View {
        TranslationView()
    }
}

struct ImageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentImageView()
        }
    }
}
