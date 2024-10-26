//
//  VoiceView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.12.2023.
//

import SwiftUI

struct VoiceView: View {
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @StateObject var viewModel = VoiceViewModel()
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    
    @FocusState private var fieldIsFocused: Bool
    @FocusState private var focusedField: Field?
    private enum Field: Int, CaseIterable {
        case message
    }
    @State var promptCurrent: String = ""
    @State var showEmptyErrorToast: Bool = false
    
    @State private var showDownloadSuccess = false
    @State private var showDownloadError = false
    @State private var isDownloadLoading = false
    @State private var isPresented = false
    @State var showSuccessToast = false
    @State var showErrorToast = false
    var rewardAd: RewardedAd = RewardedAd()
    
    @EnvironmentObject var appState: AppState
    
    
    
    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading,spacing: 0) {
                
                ZStack {
                    HStack{
                        Spacer()
                        
                        HStack(spacing: 10){
                            if !upgradeViewModel.isSubscriptionActive {
                                Image("AppVectorIcon")
                                    .resizable().scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.green_color)
                            }
                            
                            
                            Text(upgradeViewModel.isSubscriptionActive ? "PRO" : String(viewModel.freeMessageCount)).modifier(UrbanistFont(.bold, size: 20)).multilineTextAlignment(.center)
                                .foregroundColor(Color.green_color)
                        }.padding(.horizontal,10).padding(.vertical,2).background(Color.green_color.opacity(0.2)).cornerRadius(99, corners: .allCorners).padding(.trailing, 20)
                        
                    }
                    
                    AppBar(title: "text_to_speech").padding(.trailing,20)
                    
                    
                }
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(alignment: .leading,spacing: 0) {
                        
                        
                        TextField("please_enter_prompt".localize(language), text: $promptCurrent,axis: .vertical)
                            .focused($fieldIsFocused)
                            .focused($focusedField, equals: .message)
                            .lineLimit(10)
                            .frame(height: 150, alignment: .top)
                            .padding(.trailing,30)
                            .padding(15)
                            .background(fieldIsFocused ? Color.green_color.opacity(0.2) : Color.gray_color ).cornerRadius(16)
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        Color.green_color, lineWidth: fieldIsFocused ? 1.5 : 0
                                    )
                            })
                            .modifier(UrbanistFont(.semi_bold, size: 16))
                            .padding(.trailing,20)
                            .padding(.top,10)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    HStack(alignment: .center, spacing: 0){
                                        
                                        Button("done".localize(language)) {
                                            focusedField = nil
                                        }.frame(maxWidth: .infinity,alignment : .trailing)
                                    }
                                    
                                }
                            }
                            .onTapGesture {
                                fieldIsFocused = true
                            }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                
                                ForEach(viewModel.voiceStylesList, id: \.self) { voiceStyle in
                                    VoiceStyleItem(text: voiceStyle.voiceName, imageName: voiceStyle.image, selected: viewModel.selectedValue == voiceStyle.voice, isPlaying: viewModel.playingVoice == voiceStyle.voiceFile) {
                                        viewModel.selectedValue = voiceStyle.voice
                                        viewModel.selectedImage = voiceStyle.image
                                        
                                        Task {
                                            await viewModel.playPauseVoice(voiceFile: voiceStyle.voiceFile)
                                        }
                                        
                                    }.padding(.horizontal, 5)
                                }
                            }
                            .padding(.vertical, 40)
                        }
                        
                        
                        if  viewModel.showAdsAndProVersion
                        {
                            AdsAndProVersionForGenerations(onClickWatchAd: {
                                _ = self.rewardAd.showAd {
                                    viewModel.showAdsAndProVersion = false
                                    viewModel.increaseFreeMessageCount()
                                    self.rewardAd.load()
                                }
                            },onClickUpgrade: {
                                isPresented = true
                            }).transition(.scaleOnly)
                        }
                        
                        Button {
                            Task {
                                if viewModel.isLoading {
                                    return
                                }
                                
                                if promptCurrent.isEmpty {
                                    showEmptyErrorToast = true
                                    return
                                }
                                focusedField = nil
                                viewModel.pauseVoice()
                              //  await viewModel.generateVoice(prompt: promptCurrent )
                            }
                        } label: {
                            HStack
                            {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(2, anchor: .center)
                                        .frame(width: 30, height: 30)
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.text_color))
                                }else
                                {
                                    Text("convert_to_speech".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white).shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6).padding(5)
                                }
                                
                            }.padding(10)
                                .frame(maxWidth:  .infinity)
                                .background(Color.green_color).cornerRadius(99)
                                .padding(.trailing,20)
                            
                            
                        }.buttonStyle(BounceButtonStyle())
                        
                        Spacer()
                    }
                    .frame(maxHeight:.infinity)
                }
                
            }.frame(maxHeight:.infinity).padding(.leading,20).padding(.bottom,5)
            
            
            ZStack{
                if viewModel.isGenerated {
                    
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                           // viewModel.isGenerated.toggle()
                        }.onAppear{
                            appState.hideBottomNav = true
                        }
                        .onDisappear{
                            appState.hideBottomNav = false
                        }
                    
                    VStack{
                        ZStack(alignment: .bottom)
                        {
                                                        
                            Image(viewModel.selectedImage).centerCropped().frame( height: 350)


                            if viewModel.isPlayingFromURL {
                                LottieView(animationName: "speechWave").frame(height: 60).padding(.horizontal, 5)
                            }
                            
                        }
                        
                        Spacer().frame(height: 10)
                        
                        HStack(spacing: 10) {
                            
                            Text(formatTime(viewModel.currentTime)).modifier(UrbanistFont(.bold, size: 14)).foregroundColor(.white)

                                    Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: viewModel.sliderEditingChanged).accentColor(.green_color)
                            
                            Text(formatTime(viewModel.duration)).modifier(UrbanistFont(.bold, size: 14)).foregroundColor(.white)

                        }.padding(.horizontal, 15)
                        
                        Spacer().frame(height: 10)
                        
                        Button {
                            if viewModel.isPlayingFromURL {
                                viewModel.pauseVoice()
                            }else
                            {
                                Task {
                                    await viewModel.playVoice()
                                }
                            }
                            
                            
                        } label: {
                            
                            Image(viewModel.isPlayingFromURL ? "Pause" : "Play")
                                .resizable().scaledToFill()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.text_color)
                                .padding(10)
                                .background(Color.gray_color).cornerRadius(99, corners: .allCorners)
                            
                        }
                        
                        
                        Spacer().frame(height: 10)
                        
                        
                        HStack(spacing: 15){
                            Button {
                                viewModel.isGenerated.toggle()
                                showDownloadSuccess = false
                            } label: {
                                
                                Text("cancel".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.green_color) .frame(height: 55).frame(maxWidth: .infinity)
                                    .background(Color.green_color.opacity(0.2)).cornerRadius(99)
                            }.buttonStyle(BounceButtonStyle())
                            
                            
                            Button {

                                if viewModel.isDownloading {
                                    return
                                }
    
                                viewModel.isDownloading = true
                           
                                
                                viewModel.downloadAudio(from: viewModel.currentlyPlayingFileURL!) { result in
                                    viewModel.isDownloading = false
                                               switch result {
                                               case .success(let fileURL):
                                                   print("Downloaded to: \(fileURL)")
                                                   showDownloadSuccess = true
                                                   // Handle the downloaded file, e.g., play the audio or move it to a permanent location
                                               case .failure(let error):
                                                   print("Error: \(error)")
                                                   showDownloadError = true
                                                   // Handle the error
                                               }
                                           }
                            } label: {
                                
                                HStack(alignment: .center, spacing: 10){
                                    
                                    
                                    if isDownloadLoading {
                                        ProgressView()
                                            .scaleEffect(2, anchor: .center)
                                            .frame(width: 30, height: 30)
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.text_color))
                                    }else if showDownloadSuccess
                                    {
                                        
                                        Image("Done")
                                            .resizable().scaledToFill()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor( .text_color )
                                        
                                        
                                        Text("done".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white)
                                        
                                    }else
                                    {
                                        Text("download".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white)
                                    }
                                    
                                }.frame(height: 55).frame(maxWidth: .infinity)
                                    .background(Color.green_color).cornerRadius(99)
                                    .shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6)
                                
                            }.buttonStyle(BounceButtonStyle())
                        }.padding(15)
                        
                    }
                    .background(   Color.light_gray )
                    .cornerRadius(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.card_border, lineWidth: 2)
                    ).padding(.vertical, 15).padding(.horizontal, 20)
                        .animation(.easeIn, value: viewModel.isGenerated)
                    
                }
                
                
            }
            
        }.onAppear{
            viewModel.getFreeMessageCount()
        }
        .fullScreenCover(isPresented: $isPresented){
            UpgradeView(showSuccessToast: $showSuccessToast, showErrorToast: $showErrorToast)
        }
        .popup(isPresented: $showEmptyErrorToast) {
            HStack(alignment: .center){
                
                Text("please_enter_prompt".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                
            }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                .frame(maxWidth: .infinity,alignment : .center).background(Color.red_color)
            
            
        } customize: {
            $0
                .type (.toast)
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .dragToDismiss(true)
        }
        .popup(isPresented: $showErrorToast) {
            HStack(alignment: .center){
                
                Text("pro_version_not_purchased".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color)
                
            }.padding(EdgeInsets(top: 56, leading: 16, bottom: 16, trailing: 16))
                .frame(maxWidth: .infinity,alignment : .center).background(Color.red_color)
            
            
        } customize: {
            $0
                .type (.toast)
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .dragToDismiss(true)
        }
        
    }
    
    func formatTime(_ time: Double) -> String {
         let minutes = Int(time) / 60
         let seconds = Int(time) % 60
         return String(format: "%02d:%02d", minutes, seconds)
     }
    
  
}


struct VoiceStyleItem: View {
    let text: String
    let imageName: String
    let selected: Bool
    let isPlaying: Bool
    var onClick: () -> Void
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var body: some View {
        
        Button {
            onClick()
        } label: {
            
            VStack(spacing: 5) {
                
                ZStack(alignment: .bottom)
                {
                    
                    
                    Image(imageName == "none" ? "None" : imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color.text_color)
                        .background(Color.light_gray)
                        .frame(width: 120, height: 200)
                    
                    if isPlaying {
                        LottieView(animationName: "speechWave").frame(height: 40).padding(.horizontal, 5)
                    }
                    
                }
                
                
                Text(text.localize(language))
                    .modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                    .foregroundColor(Color.text_color) .padding(5)
            }
            .background(selected ? Color.green_color : Color.light_gray)
            .cornerRadius(16)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selected ? Color.green_color : Color.card_border , lineWidth:  2
                    )
            })
        }.buttonStyle(BounceButtonStyle())
        
        
        
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

#Preview {
    VoiceView()
}
