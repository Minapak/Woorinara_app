import SwiftUI

struct ScanView: View {
    @State private var showScanPreARCView = false
    @State private var showScanPrePassView = false
    @State private var showSkipView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 10) {
                    // Instructions
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Please prepare your")
                            .font(.system(size: 32).bold())
                            .foregroundColor(.black)
                        
                        Text("identifiable ID.")
                            .font(.system(size: 32).bold())
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                        
                        Text("From a bright place.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text("Make sure the shadow doesn't fade.")
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
                        // Alien Registration Card Button
                        NavigationLink(destination: ScanPreARCView(), isActive: $showScanPreARCView) {
                            Button("Alien Registration Card") {
                                showScanPreARCView = true
                            }
                            .frame(width: 344, height: 50)
                            .font(.system(size: 16, weight: .bold))
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }

                        // Passport Button
                        NavigationLink(destination: ScanPrePassView(), isActive: $showScanPrePassView) {
                            Button("Passport") {
                                showScanPrePassView = true
                            }
                            .frame(width: 344, height: 50)
                            .font(.system(size: 16, weight: .bold))
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }

                        // Skip Button
                        NavigationLink(destination: MyInfoView(), isActive: $showSkipView) {
                            Button("Skip") {
                                showSkipView = true
                            }
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
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            Text("")
                                .foregroundColor(.blue)
                        })
        }
    }
}



struct ContentScanView: View {
    var body: some View {
        ScanView()
    }
}


struct ScanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentScanView()
        }
    }
}
