import SwiftUI
import UIKit

// Custom ScrollView with zooming functionality
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = context.coordinator

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)

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
        context.coordinator.hostingController.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content))
    }

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

// Main TranslateView
struct TranslateView: View {
    var languageOptions = ["Korean", "English", "Vietnamese", "Chinese", "Japanese"]
    var imageOptions = ["af", "af_e", "af_v", "af_c", "af_j"]
    
    @State private var selectedLanguage: String? = nil
    @State private var isLanguageDropdownOpen = false
    @State private var selectedImage = "af_high"
    @State private var navigateToAFInfoView = false // Navigation to AFInfoView
    @State private var translationCompleted = false // Show success banner
    @State private var buttonLabel = "Translation" // Button label
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button("Korean") { }
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

                    // Button
                    HStack {
                        Button(buttonLabel) {
                            if translationCompleted {
                                navigateToAFInfoView = true
                                buttonLabel = "Auto-fill"
                            } else {
                                translationCompleted = true
                                buttonLabel = "Auto-fill"
                            }
                        }
                        .frame(width: 350, height: 50)
                        .font(.system(size: 16, weight: .bold))
                        .background(translationCompleted ? Color.blue : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.bottom, 5)
                .padding(16)

                if translationCompleted {
                    VStack {
                        HStack {
                            Spacer()
                            Text("✔ Translation completed!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .padding(.trailing, 20)
                                .transition(.move(edge: .top))
                                .animation(.easeInOut, value: translationCompleted)
                        }
                        Spacer()
                    }
                }

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
            
            // NavigationLink triggered by `navigateToAFInfoView`
            NavigationLink(destination: AFInfoView(), isActive: $navigateToAFInfoView) {
                EmptyView()
            }
        }
    }
}
