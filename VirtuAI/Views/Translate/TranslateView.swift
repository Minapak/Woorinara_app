import SwiftUI
import UIKit

// 확대, 축소 및 이동이 가능한 커스텀 ScrollView
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        // 확대/축소 설정
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0 // 필요에 따라 조정 가능
        scrollView.delegate = context.coordinator

        // SwiftUI 뷰를 UIHostingController에 래핑하여 추가
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

        // Auto Layout을 사용하여 hostedView가 scrollView 크기에 맞게 설정
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostedView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hostedView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // SwiftUI 뷰가 업데이트될 때마다 hostingController의 rootView도 업데이트
        context.coordinator.hostingController.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content))
    }

    // 확대/축소를 위한 Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

// 메인 TranslateView
struct TranslateView: View {
    @State private var showPDFOverlayView = false
    var languageOptions = ["Korean", "English", "Vietnamese", "Chinese", "Japanese"]
    var imageOptions = ["af", "af_e", "af_v", "af_c", "af_j"]
    @State private var selectedLanguage: String? = nil
    @State private var isLanguageDropdownOpen = false
    @State private var selectedImage = "af"  // 기본 이미지를 선택된 옵션으로 설정
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                VStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button("Korean") {
                                showPDFOverlayView = true
                            }
                            .frame(width: 150, height: 50)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .cornerRadius(16)

                            Button(action: {
                                isLanguageDropdownOpen.toggle()
                            }) {
                                HStack {
                                    Text(selectedLanguage ?? "Language")
                                        .foregroundColor(.gray)
                                    Image(systemName: isLanguageDropdownOpen ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 150, height: 50)
                                .font(.system(size: 16, weight: .bold))
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                            }
                        }
                    }

                    Spacer()

                    // ZoomableScrollView로 이미지 표시
                    ZoomableScrollView {
                        Image(selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            .padding()
                    }

                    Spacer()

                    // 번역 버튼
                    HStack {
                        Button("Auto-Fill") {
                            showPDFOverlayView = true
                        }
                        .frame(width: 350, height: 50)
                        .font(.system(size: 16, weight: .bold))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.bottom, 5)
                .padding(16)

                // 드롭다운 메뉴
                if isLanguageDropdownOpen {
                    VStack {
                        Spacer().frame(height: 60)
                        VStack(alignment: .leading) {
                            ForEach(languageOptions.indices, id: \.self) { index in
                                Button(action: {
                                    selectedLanguage = languageOptions[index]
                                    selectedImage = imageOptions[index]
                                    isLanguageDropdownOpen = false
                                }) {
                                    Text(languageOptions[index])
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5))
                        )
                        .shadow(radius: 5)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.05)
                        Spacer()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: isLanguageDropdownOpen)
                }
            }
            .navigationTitle("Translation")
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
            .background(
                NavigationLink(destination: AFTransView(), isActive: $showPDFOverlayView) { EmptyView() }
            )
        }
    }
}
