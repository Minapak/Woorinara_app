import SwiftUI

struct MyAccount: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Subtitle
            Text("My Account")
                .font(.system(size: 28, weight: .bold))
                .padding(.top)
            
            Text("If the recognized content is different from the real thing, usage may be restricted.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.bottom)
            
            // List of account options
            VStack(spacing: 20) {
                NavigationLink(destination: MyInfoView()) {
                    AccountOptionRow(title: "My Information")
                }
                
                NavigationLink(destination: Text("My ID & Nickname")) {
                    AccountOptionRow(title: "My ID & Nickname")
                }
                
                NavigationLink(destination: ChangePWView()) {
                    AccountOptionRow(title: "Change Password")
                }
                
                NavigationLink(destination: LogOutView()) {
                    AccountOptionRow(title: "Log Out")
                }
                
                NavigationLink(destination: DeleteMemberView()) {
                    AccountOptionRow(title: "Delete Account")
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // Shows the back button
    }
}

struct AccountOptionRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct MyAccount_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyAccount()
        }
    }
}
