//
//  AFDoneView.swift
//  VirtuAI
//
//  Created by 박은민 on 11/1/24.
//
import SwiftUI

struct AFDoneView: View {
    @State private var showAlertForRedText = false
    @State private var showAlertForFileName = false
    @State private var showFileTypeSelection = false
    @State private var fileName: String = "Alteration of Residence"
    @State private var selectedFileTypes: [String] = ["pdf"]

    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])
                VStack(alignment: .center, spacing: 0) {
                    //AppBar(title: "", isMainPage: true)
                    
                    VStack {
                        Text("Auto-fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        
                        Text("You should edit or delete the red texts \nbefore submitting")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                        
                        Image("af_done")
                            .resizable()
                            .frame(width: 250, height: 350)
                            .padding()
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                // Edit button action
                            }) {
                                Text("Edit")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showAlertForRedText = true
                            }) {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }.frame(maxWidth: UIScreen.main.bounds.width * 1)
                }
            }
            .alert(isPresented: $showAlertForRedText) {
                Alert(
                    title: Text("Red text is a sample value, so it will be deleted if not edited"),
                    message: Text("Everything else will be saved"),
                    primaryButton: .default(Text("Edit")),
                    secondaryButton: .default(Text("OK"), action: {
                        showAlertForFileName = true
                    })
                )
            }
            .alert("Save as...", isPresented: $showAlertForFileName) {
                VStack {
                    TextField("Enter file name", text: $fileName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Button("Save") {
                        showFileTypeSelection = true
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .actionSheet(isPresented: $showFileTypeSelection) {
                ActionSheet(
                    title: Text("Save file"),
                    message: Text("Choose file format"),
                    buttons: [
                        .default(Text("PDF"), action: { toggleFileType("pdf") }),
                        .default(Text("PNG"), action: { toggleFileType("png") }),
                        .default(Text("Done"))
                    ]
                )
            }
        }
    }

    private func toggleFileType(_ fileType: String) {
        if selectedFileTypes.contains(fileType) {
            selectedFileTypes.removeAll { $0 == fileType }
        } else {
            selectedFileTypes.append(fileType)
        }
    }
}

struct AFDoneView_Previews: PreviewProvider {
    static var previews: some View {
        AFDoneView()
    }
}
