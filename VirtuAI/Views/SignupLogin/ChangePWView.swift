import SwiftUI

struct ChangePWView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showCurrentPassword: Bool = false
    @State private var showNewPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Change Password")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)

                Text("Please change the password.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                PasswordField(title: "Current Password", text: $currentPassword, isSecure: $showCurrentPassword)
                PasswordField(title: "New Password", text: $newPassword, isSecure: $showNewPassword)
                PasswordField(title: "Confirm Password", text: $confirmPassword, isSecure: $showConfirmPassword)

                Spacer()

                Button(action: {
                    // Action for changing the password
                }) {
                    Text("Change")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty ? Color.gray.opacity(0.2) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PasswordField: View {
    var title: String
    @Binding var text: String
    @Binding var isSecure: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .bold()
                Text("*")
                    .foregroundColor(.red)
            }
            .padding(.bottom, 4)

            HStack {
                if isSecure {
                    SecureField("Placeholder text", text: $text)
                } else {
                    TextField("Placeholder text", text: $text)
                }
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
        }
    }
}

struct ChangePWView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePWView()
    }
}
