import SwiftUI

struct ARCInfoView: View {
    @State private var showScanPreARCView = false
    @State private var showSkipAlert = false
    @State private var showContentView = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(Constants.isFirstLogin) private var isFirstLogin = true
    @AppStorage(Constants.hasCompletedARC) private var hasCompletedARC = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white).ignoresSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 10) {
                    // Instructions
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Please prepare your ARC and Passport.")
                            .font(.system(size: 32).bold())
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                        
                        Text("Prepare to scan your ARC and passport.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text("Make sure the documents are positioned clearly and well-lit for the best results.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Image("920")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 344, height: 190)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding()
                    
                    Spacer()

                    VStack(alignment: .center, spacing: 10) {
                        // ARC Button
                        Button(action: {
                            showScanPreARCView = true
                        }) {
                            Text("ARC")
                                .frame(width: 344, height: 50)
                                .font(.system(size: 16, weight: .bold))
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        
                        // Skip Button
                        Button(action: {
                            isFirstLogin = false
                            hasCompletedARC = true
                            showContentView = true
                        }) {
                            Text("Skip")
                                .frame(width: 344, height: 30)
                                .font(.system(size: 16, weight: .regular))
                                .background(Color.white)
                                .foregroundColor(.gray)
                                .cornerRadius(16)
                        }
                        .alert(isPresented: $showSkipAlert) {
                            Alert(
                                title: Text("No user information entered."),
                                message: Text("To use the auto-fill feature, please enter your information. Prepare to scan your ARC and passport."),
                                primaryButton: .default(Text("Back")) {
                                    presentationMode.wrappedValue.dismiss()
                                },
                                secondaryButton: .default(Text("Scan")) {
                                    showScanPreARCView = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 5)
                
                // Navigation Links outside the VStack to avoid nesting issues
                NavigationLink(
                    destination: ScanPreARCView(),
                    isActive: $showScanPreARCView
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: ContentView(),
                    isActive: $showContentView
                ) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .imageScale(.large)
            })
        }
    }
}

struct ContentARCInfoView: View {
    var body: some View {
        ARCInfoView()
    }
}

struct ScanARCInfoViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentARCInfoView()
        }
    }
}
