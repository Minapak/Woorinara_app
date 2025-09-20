//
//  FindPWView.swift
//  VirtuAI
//
//  Created by 박은민 on 11/1/24.
//

import SwiftUI
import AlertToast

struct FindPWView: View {
    @State private var email: String = ""
    @State private var verificationCode: String = ""
    @State private var isCodeSent: Bool = false
    @State private var isCodeVerified: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var isEmailValid: Bool = false
    @State private var isCodeValid: Bool = false
    
    @State private var showingSuccessAlert: Bool = false
    @EnvironmentObject var viewModel: AlertViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Find Password")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            
            Text("Please enter the email you used for verification at the time of registration.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // Email Input
            VStack(alignment: .leading) {
                HStack {
                    Text("Email")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("*")
                        .foregroundColor(.red)
                }
                
                HStack {
                    TextField("Enter your Email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isEmailValid ? Color.green : Color.gray, lineWidth: 1)
                        )
                        .onChange(of: email) { newValue in
                            isEmailValid = newValue.contains("@") && newValue.contains(".")
                        }
                    
                    Button(action: {
                        if isEmailValid {
                            isCodeSent = true
                        } else {
                            alertMessage = "Please enter a valid email address."
                            showAlert = true
                        }
                    }) {
                        Text("Send Code")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(isEmailValid ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isEmailValid)
                }
            }
            
            // Verification Code Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Verification code")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                HStack {
                    TextField("Enter your code", text: $verificationCode)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isCodeValid ? Color.green : Color.gray, lineWidth: 1)
                        )
                        .onChange(of: verificationCode) { newValue in
                            isCodeValid = newValue.count == 6
                        }
                    
                    Button(action: {
                        if isCodeValid {
                            isCodeVerified = true
                            showingSuccessAlert = true
                        } else {
                            alertMessage = "Please enter a valid 6-digit code."
                            showAlert = true
                        }
                    }) {
                        Text("Verify")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(isCodeSent ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isCodeSent)
                }
                
                if isCodeSent {
                    Button(action: {
                        // Resend code action here
                    }) {
                        Text("Resend verification code")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }
            
            Spacer()
            
            // Next Button
            Button(action: {
                // Next action here
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCodeVerified ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!isCodeVerified)
            
            Spacer()
        }
        .padding()
        .toast(isPresenting: $showingSuccessAlert) {
            AlertToast(type: .complete(Color.green), title: "Verification Successful!")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct FindPWView_Previews: PreviewProvider {
    static var previews: some View {
        FindPWView()
            .environmentObject(AlertViewModel())
    }
}
