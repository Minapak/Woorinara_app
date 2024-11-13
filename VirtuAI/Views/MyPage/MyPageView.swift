import SwiftUI

struct MyPageView: View {
    @State private var selectedIndex = 4  // Set to 4 if MyPage is the last tab (adjust if needed)

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
               
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                        .padding(.horizontal, 20)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            // User Info Section
                            NavigationLink(destination: MyAccount()) {
                                HStack {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue.opacity(0.3))
                                    
                                    VStack(alignment: .leading) {
                                        Text("User Name")
                                            .font(.system(size: 20, weight: .bold))
                                        
                                        Text("user@naver.com")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            
                            Divider()
                            
                            // Registered ID Section
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Registered ID")
                                    .font(.headline)
                                
                                NavigationLink(destination: Text("Passport")) {
                                    HStack {
                                        Text("Passport")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                NavigationLink(destination: Text("Alien Registration Card")) {
                                    HStack {
                                        Text("Alien Registration Card")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                            // My Document Folder Section
                            VStack(alignment: .leading, spacing: 20) {
                                Text("My Document Folder")
                                    .font(.headline)
                                
                                NavigationLink(destination: Text("Saved Documents")) {
                                    HStack {
                                        Text("Saved Documents")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                NavigationLink(destination: Text("Trash")) {
                                    HStack {
                                        Text("Trash")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 5)
                .padding(16)
                
//                // Custom Bottom Navigation
//                CustomTabView(
//                    tabs: TabType.allCases.map { $0.tabItem },
//                    selectedIndex: $selectedIndex
//                )
//                .padding(.bottom, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
