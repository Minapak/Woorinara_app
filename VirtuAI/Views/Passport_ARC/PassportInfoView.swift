import SwiftUI

struct PassportInfoView: View {
    @State private var showScanPrePassView = false
    @State private var showSkipAlert = false
    @State private var showContentView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white).ignoresSafeArea()
                
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
                        // Passport Button
                        Button(action: {
                            showScanPrePassView = true
                        }) {
                            Text("Passport")
                                .frame(width: 344, height: 50)
                                .font(.system(size: 16, weight: .bold))
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 8)

                        // Skip Button
                        Button(action: {
                            showContentView = true
                        }) {
                            Text("Skip")
                                .frame(width: 344, height: 30)
                                .font(.system(size: 16, weight: .regular))
                                .background(Color.white)
                                .foregroundColor(.gray)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 5)
                
                // Navigation Links outside the VStack
                NavigationLink(
                    destination: ScanPrePassView(),
                    isActive: $showScanPrePassView
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

struct ContentPassportInfoView: View {
    var body: some View {
        PassportInfoView()
    }
}

struct ScanPassportInfoViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentPassportInfoView()
        }
    }
}
