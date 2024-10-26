//
//  AssistantsView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI
import Photos

struct GenerateImageView: View {
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @StateObject var viewModel = GenerateImageViewModel()
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


    let imageStylesList: [ImageStyle] = [
        ImageStyle(text: "no_style", imageName: "none", prompt: ""),
        ImageStyle(text: "realistic", imageName: "Realistic", prompt:Constants.Prompts.REALISTIC),
        ImageStyle(text: "cartoon", imageName: "Cartoon", prompt: Constants.Prompts.CARTOON),
        ImageStyle(text: "pencil_sketch", imageName: "PencilSketch", prompt: Constants.Prompts.PENCIL_SKETCH),
        ImageStyle(text: "oil_painting", imageName: "OilPainting", prompt: Constants.Prompts.OIL_PAINTING),
        ImageStyle(text: "water_color", imageName: "WaterColor", prompt: Constants.Prompts.WATER_COLOR),
        ImageStyle(text: "pop_art", imageName: "PopArt", prompt: Constants.Prompts.POP_ART),
        ImageStyle(text: "surrealist", imageName: "Surrealist", prompt: Constants.Prompts.SURREALIST),
        ImageStyle(text: "pixel_art", imageName: "PixelArt", prompt: Constants.Prompts.PIXEL_ART),
        ImageStyle(text: "nouveau", imageName: "Nouveau", prompt: Constants.Prompts.NOUVEAU),
        ImageStyle(text: "abstract_art", imageName: "AbstractArt", prompt: Constants.Prompts.ABSTRACT_ART)
    ]
    
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
                    
                    AppBar(title: "generate_image").padding(.trailing,20)
                    
                    
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
                            HStack(spacing: 10) {
                                
                                ForEach(imageStylesList, id: \.self) { imageStyle in
                                    ImageStyleItem(text: imageStyle.text, imageName: imageStyle.imageName, selected: viewModel.selectedValue == imageStyle.text) {
                                        viewModel.selectedValue = imageStyle.text
                                        viewModel.selectedPrompt = imageStyle.prompt
                                    }
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
                                //await viewModel.generateImage(prompt: promptCurrent)
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
                                    Text("generate_image".localize(language)).modifier(UrbanistFont(.bold, size: 16)).foregroundColor(.white).shadow(color: .black.opacity(0.2),radius: 6, x: 0, y: 6).padding(5)
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
            
        }.onAppear{
            viewModel.getFreeMessageCount()
        }
        .fullScreenCover(isPresented: $isPresented){
            UpgradeView(showSuccessToast: $showSuccessToast, showErrorToast: $showErrorToast)
        }
        .sheet(isPresented: $viewModel.isGenerated) {
           VStack{
               Rectangle()
                   .fill(Color.card_border)
                   .frame(width : 60, height: 4)
                   .cornerRadius(10, corners: .allCorners)
                     .padding(10)
               
               Text("generated_image".localize(language)).modifier(UrbanistFont(.bold, size: 22)).multilineTextAlignment(.center)
                   .foregroundColor(Color.text_color).padding(.top, 4)
               
               Rectangle()
                   .fill(Color.card_border)
                   .frame( height: 2)
                   .cornerRadius(10, corners: .allCorners)
                     .padding(10)
               
               Spacer().frame(height: 10)
               GeometryReader { geometry in

               AsyncImage(url: URL(string: viewModel.generatedImageURL)) { image in
                        image.resizable()
                       .scaledToFill()
                                      .frame(width: geometry.size.width, height: geometry.size.width)
                                      .clipped()
                    } placeholder: {
                                   
                        ProgressView()
                                 .scaleEffect(2, anchor: .center)
                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                                 .aspectRatio(1, contentMode: .fit)
                                 .progressViewStyle(CircularProgressViewStyle(tint: Color.green_color))


                    }
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
                       
                       if isDownloadLoading {
                           return
                       }

                       let url = URL(string: viewModel.generatedImageURL)!
                       isDownloadLoading = true
                       downloadAndSaveImage(from: url) { success, error in
                               isDownloadLoading = false
                               if success {
                                   showDownloadSuccess = true
                               } else {
                                   print("errorrrr")
                                   showDownloadError = true
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
               }
               
           }.padding(15).frame(maxWidth: .infinity,maxHeight:.infinity ,  alignment: .topLeading)
           .presentationDetents([.height(620)])
           .presentationBackground {
               VStack{
                   Spacer()
                   
               }.padding(15).frame(maxWidth: .infinity,maxHeight:.infinity ,  alignment: .topLeading)
                   .background(   Color.light_gray )
                   .cornerRadius(50)
                   .overlay(
                       RoundedRectangle(cornerRadius: 50)
                           .stroke(Color.card_border, lineWidth: 2)
                   ).padding(3)
           }.interactiveDismissDisabled()
                .popup(isPresented: $showDownloadError) {
                    HStack(alignment: .center){
                        
                        Text("please_check_permisson".localize(language)).modifier(UrbanistFont(.semi_bold, size: 20)).multilineTextAlignment(.center)
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
    
    
    func downloadAndSaveImage(from url: URL, completion: @escaping (Bool, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            // Save image to photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { saved, error in
                DispatchQueue.main.async {
                    completion(saved, error)
                }
            }
        }.resume()
    }
    
    
}

struct ImageStyleItem: View {
    let text: String
    let imageName: String
    let selected: Bool
    var onClick: () -> Void
    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var body: some View {
        
        Button {
            onClick()
        } label: {
       
            VStack(spacing: 0) {
                
                Image(imageName == "none" ? "None" : imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.text_color)
                    .background(Color.light_gray)
                    .frame(width: 120, height: 120)
                
                
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

struct AdsAndProVersionForGenerations : View
{
    var onClickWatchAd : () -> Void = {}
    var onClickUpgrade : () -> Void = {}
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    var body: some View {
        VStack(spacing: 0){
            Text("you_reach_free_message_limit".localize(language)).modifier(UrbanistFont(.medium, size: 14)).foregroundColor(.inactive_input).padding(10).frame(maxWidth: .infinity).multilineTextAlignment(.center)
                .background(Color.red_shadow).cornerRadius(14)
                
            
            HStack(spacing: 10){
                Button {
                    onClickUpgrade()
                } label: {
                    HStack(alignment: .center,spacing: 20) {
                        
                        Image("Star")
                            .resizable().scaledToFill()
                            .frame(width: 25, height: 25)
                            .foregroundColor( .green_color )
                        
                        Text("upgrade_to_pro".localize(language)).modifier(UrbanistFont(.bold, size: 14)).multilineTextAlignment(.leading)
                            .foregroundColor(Color.inactive_input)
                        
                    }.padding(.horizontal,15).frame(height: 60, alignment: .center).frame(maxWidth: .infinity)
                        .background(   Color.light_gray )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.card_border, lineWidth: 2)
                        ).padding(.vertical,10)
                }.buttonStyle(BounceButtonStyle())
                
                Button {
                    onClickWatchAd()
                } label: {
                    HStack(alignment: .center,spacing: 20) {
                        
                        Image("Video")
                            .resizable().scaledToFill()
                            .frame(width: 25, height: 25)
                            .foregroundColor( .green_color )
                        
                        Text("watch_ad".localize(language)).modifier(UrbanistFont(.bold, size: 14)).multilineTextAlignment(.leading)
                            .foregroundColor(Color.inactive_input)
                        
                    }.padding(.horizontal,15).frame(height: 60, alignment: .center).frame(maxWidth: .infinity)
                        .background(   Color.light_gray )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.card_border, lineWidth: 2)
                        ).padding(.vertical,10)
                }.buttonStyle(BounceButtonStyle())
            }
        }.padding(.trailing,20).padding(.bottom, 30)
        
        
        
    }
}

struct GenerateImageView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateImageView()
    }
}

extension AnyTransition {
    static var scaleOnly: AnyTransition {
        .scale(scale: 0.5) // Adjust the starting scale as needed
    }
}
