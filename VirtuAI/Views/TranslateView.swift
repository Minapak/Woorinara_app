import SwiftUI

struct TranslateView: View {
    @State private var showTranslationView = false
    var languageOptions = ["English", "Vietnamese", "Chinese", "Japanese"]
    var imageOptions = ["af_e", "af_v", "af_c", "af_j"]
    @State private var selectedLanguage: String? = nil
    @State private var isLanguageDropdownOpen = false
    @State private var selectedImage = "af"
    
    // Zoom state variables
    @State private var scale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 10) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button("Korean") {
                                showTranslationView = true
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
                    
                    // Image display with zoom-in and zoom-out functionality
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 400)
                        .scaleEffect(scale)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding()
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScaleValue * value
                                }
                                .onEnded { _ in
                                    lastScaleValue = scale
                                }
                        )

                    Spacer()
                    
                    // Translation button remains fixed
                    HStack {
                        Button("Translation") {
                            showTranslationView = true
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
                
                // Overlay the dropdown menu above other elements
                if isLanguageDropdownOpen {
                    VStack {
                        Spacer().frame(height: 60) // Offset to position dropdown below button
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
                        .frame(width: UIScreen.main.bounds.width * 0.9) // Adjust width to 90% of screen width
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5))
                        )
                        .shadow(radius: 5)
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.05) // Center align the dropdown
                        Spacer()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: isLanguageDropdownOpen)
                }
            }
            .background(
                NavigationLink(destination: PDFClickViewer(), isActive: $showTranslationView) { EmptyView() }
            )
        }
    }
}

struct ContentTranslateView: View {
    var body: some View {
        TranslateView()
    }
}

struct TranslateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentTranslateView()
        }
    }
}
