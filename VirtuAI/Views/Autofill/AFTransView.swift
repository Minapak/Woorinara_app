//
//  AFDoneView.swift
//  VirtuAI
//
//  Created by 박은민 on 11/1/24.
//
import SwiftUI

struct AFTransView: View {
    @State private var showAlertForRedText = false
    @State private var showAlertForFileName = false
    @State private var showFileTypeSelection = false
    @State private var fileName: String = "Alteration of Residence"
    @State private var selectedFileTypes: [String] = ["pdf"]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color(.white).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    
                    //AppBar(title: "", isMainPage: true)
                    
                    VStack (alignment: .leading ,spacing: 0){
                        Spacer()
                        Text("The integrated application form will be automatically \nfilled out based on the registered user information")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.leading) // 텍스트는 왼쪽 정렬
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center) // 여러 줄을 가운데 정렬
                            .foregroundColor(.gray)
                            .padding(12) // 프레임에 12씩 패딩 추가
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)

                        Spacer()
                        Image("af")
                            .resizable()
                            .frame(width: 298, height: 422)
                            .padding()
                        Spacer()
                        HStack(spacing: 0) {
                            Button(action: {
                                // Edit button action
                            }) {
                                Text("Select Application/Report")
                                    .font(.system(size: 18).bold())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            
                        
                        }.padding(.bottom, 5)
                     
                    }.padding(.horizontal, 16)
                }
            }
            .navigationTitle("Auto-fill") // 타이틀을 중앙 정렬
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

struct AFTransView_Previews: PreviewProvider {
    static var previews: some View {
        AFTransView()
    }
}
