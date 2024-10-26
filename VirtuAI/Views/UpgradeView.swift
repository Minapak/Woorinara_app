//
//  UpgradeView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 11.06.2023.
//

import SwiftUI
import RevenueCat
import PopupView
struct UpgradeView: View {

    
    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    @Environment(\.dismiss) var dismiss

    @State var currentOffering: Offering?
    @EnvironmentObject var upgradeViewModel: UpgradeViewModel
    @Binding var showSuccessToast : Bool
    @Binding var showErrorToast  : Bool
    
    var body: some View {
        ZStack
        {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack( alignment: .leading, spacing: 0)
            {
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image("Close")
                            .resizable().scaledToFill()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.text_color)
                            .padding(5)
                            .background(Color.gray_shadow)
                            .cornerRadius(99, corners: .allCorners)
                    }
                    
                    Spacer()
                    
                    Button {
                        restorePurchase()
                    } label: {
                        
                        Text("restore".localize(language)).modifier(UrbanistFont(.medium, size: 12)).multilineTextAlignment(.center)
                            .foregroundColor(Color.text_color).padding(.vertical, 5).padding(.horizontal, 10)
                            .background(Color.gray_shadow)
                            .cornerRadius(99, corners: .allCorners)
                        
                    }
                    
                }.padding(.horizontal,20)
                ScrollView(.vertical,showsIndicators: false){
                    VStack(alignment: .center,spacing: 20) {
                        Image("AppVectorIcon")
                            .resizable().scaledToFill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green_color)
                        
                        HStack(alignment: .center,spacing: 5) {
                            
                            Text( "app_name".localize(language)).modifier(UrbanistFont(.bold, size: 20))
                                .foregroundColor(Color.text_color)
                            
                            Text("pro".localize(language)).modifier(UrbanistFont(.bold, size: 20))
                                .foregroundColor(Color.green_color).padding(.horizontal,10).padding(.vertical,1).background(Color.green_color.opacity(0.2)).cornerRadius(99, corners: .allCorners)
                            
                        }
                        
                        VStack(alignment: .center,spacing: 10) {
                            AccessRow(name: "powered_by_chat_gpt")
                            AccessRow(name: "unlock_url")
                            AccessRow(name: "unlock_scan")
                            AccessRow(name: "unlimited_messages")
                            AccessRow(name: "cancel_anytime")
                        }.padding(10).background(Color.light_gray).cornerRadius(16, corners: .allCorners)
                        
                        if currentOffering != nil {
                            
                                VStack(alignment: .center,spacing: 10) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                    
                                        if let pkg = currentOffering!.availablePackages.first(where: {$0.identifier == Constants.WEEKLY_OFFER_ID}) {
                                      
                                            Button {
                                                purchaseProduct(pkg: pkg)
                                            } label: {
                                                VStack(alignment: .center,spacing: 0) {
                                                    
                                                    Text("weekly".localize(language)).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.green_color).padding(15)
                                                    
                                                    Rectangle()
                                                        .fill(Color.card_border)
                                                        .frame( height: 2)
                                                        .cornerRadius(10, corners: .allCorners)
                                                    
                                                    Text(pkg.storeProduct.localizedPriceString).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.text_color).padding(15)
                                                    
                                                    Text("per_week").modifier(UrbanistFont(.light, size: 11)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.text_color).padding(.bottom,10)
                                                    
                                                } .background(Color.light_gray)
                                                    .cornerRadius(16)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.card_border, lineWidth: 2)
                                                    ).frame(maxWidth: .infinity)
                                            }.buttonStyle(BounceButtonStyle())
                                            
                                        }
                                        
                                        if let pkg = currentOffering!.availablePackages.first(where: {$0.identifier == Constants.MONTHLY_OFFER_ID}) {
                                            
                                                Button {
                                                    purchaseProduct(pkg: pkg)
                                                } label: {
                                                    VStack(alignment: .center,spacing: 0) {
                                                        
                                                        Text("monthly".localize(language)).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                            .foregroundColor(Color.green_color).padding(15)
                                                        
                                                        Rectangle()
                                                            .fill(Color.card_border)
                                                            .frame( height: 2)
                                                            .cornerRadius(10, corners: .allCorners)
                                                        
                                                        Text(pkg.storeProduct.localizedPriceString).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                            .foregroundColor(Color.text_color).padding(15)
                                                        
                                                        Text("per_month").modifier(UrbanistFont(.light, size: 11)).multilineTextAlignment(.center)
                                                            .foregroundColor(Color.text_color).padding(.bottom,10)
                                                        
                                                    } .background(Color.light_gray)
                                                        .cornerRadius(16)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(Color.card_border, lineWidth: 2)
                                                        ).frame(maxWidth: .infinity)
                                                }.buttonStyle(BounceButtonStyle())
                                                
                                          
                                        }
                              
                                    }
                                    if let pkg = currentOffering!.availablePackages.first(where: {$0.identifier == Constants.ANNUAL_OFFER_ID}) {
                                        Button {
                                            purchaseProduct(pkg: pkg)

                                        } label: {
                                            ZStack
                                            {
                                                VStack(alignment: .center,spacing: 0) {
                                                    
                                                    Text("yearly".localize(language)).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.green_color).padding(15)
                                                    
                                                    Rectangle()
                                                        .fill(Color.card_border)
                                                        .frame( height: 2)
                                                        .cornerRadius(10, corners: .allCorners)
                                                    
                                                    Text(pkg.storeProduct.localizedPriceString).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.text_color).padding(15)
                                                    
                                                    Text("per_year").modifier(UrbanistFont(.light, size: 11)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.text_color).padding(.bottom,10)
                                                    
                                                } .background(Color.light_gray)
                                                    .shimmer(config: .init(tint: .white, highlight: .white.opacity(0.8),blur : 10))
                                                    .cornerRadius(16)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.green_color, lineWidth: 2)
                                                    ).frame(maxWidth: .infinity)
                                                
                                                VStack(alignment: .trailing){
                                                    Text("save85".localize(language)).modifier(UrbanistFont(.semi_bold, size: 11)).multilineTextAlignment(.center)
                                                        .foregroundColor(Color.text_color).padding(.vertical, 5).padding(.horizontal,10)
                                                        .background(Color.green_color)
                                                        .cornerRadius(16, corners: [.bottomLeft, .topRight])
                                                    Spacer()
                                                }.frame(maxWidth: .infinity, maxHeight: .infinity,alignment : .trailing)
                                                
                                                
                                            }
                                            
                                            
                                        }.buttonStyle(BounceButtonStyle())
                                    }
                                    
                               
                                }
         
                        }
                        
                        
                        Link(destination: URL(string: Constants.TERMS_OF_USE)!) {
                            HStack(alignment: .center, spacing: 10) {
                                        
                                Text("terms_and_policy".localize(language)).modifier(UrbanistFont(.semi_bold, size: 15)).foregroundColor(.blue).multilineTextAlignment(.leading)
                               
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 10){
                        
                                Image("ShieldDone")
                                    .resizable().scaledToFill()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.text_color)


                                Text("secured_by_app_store".localize(language)).modifier(UrbanistFont(.medium, size: 12)).multilineTextAlignment(.center)
                                    .foregroundColor(Color.text_color)
                              
     
                        }.frame(maxWidth: .infinity, alignment : .center)
                        
                    }.padding(.horizontal,20)
                    
                }.frame(maxWidth: .infinity)
            }
            
            
            ZStack
            {
                Rectangle()
                    .foregroundColor(Color.black)
                    .opacity(upgradeViewModel.isLoading ? 0.5: 0.0)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.green_color))
                
            }.opacity(upgradeViewModel.isLoading ? 1: 0.0).edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            
            Purchases.shared.getOfferings { offerings, error in
                
                if let offer = offerings?.current, error == nil {
                    
                    currentOffering = offer
                }
            }
        }
      
      
      
    }
    func purchaseProduct(pkg: Package )
    {
        upgradeViewModel.isLoading = true
        Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
            upgradeViewModel.isLoading = false
            if customerInfo?.entitlements.all[Constants.ENTITLEMENTS_ID]?.isActive == true {
                   
                upgradeViewModel.setThePurchaseStatus(isPro : true)
                showSuccessToast.toggle()
                 dismiss()
             }else
             {
                 upgradeViewModel.setThePurchaseStatus(isPro : false)

             }
            
            if error != nil {
                showErrorToast.toggle()
            }
         }
    }
    func restorePurchase()
    {
        upgradeViewModel.isLoading = true
        Purchases.shared.restorePurchases { (customerInfo, error) in
            
            upgradeViewModel.isLoading = false
            if customerInfo?.entitlements.all[Constants.ENTITLEMENTS_ID]?.isActive == true {
                upgradeViewModel.setThePurchaseStatus(isPro : true)
                showSuccessToast.toggle()

                dismiss()
            }else
            {
                upgradeViewModel.setThePurchaseStatus(isPro : false)
                showErrorToast.toggle()

            }
            
     
     
        }
    }
}

struct AccessRow : View
{    @AppStorage("language")
    private var language = LanguageManager.shared.selectedLanguage
    
    var name : String
    var body: some View
    {
        HStack{
            
            Image("Done")
                .resizable().scaledToFill()
                .frame(width: 11, height: 11)
                .foregroundColor(.green_color)
                .padding(7)
                .background(Color.green_color.opacity(0.2))
                .cornerRadius(99, corners: .allCorners)
            
            
            Text(name.localize(language)).modifier(UrbanistFont(.semi_bold, size: 14)).multilineTextAlignment(.center)
                .foregroundColor(Color.text_color)
            
            
            
        }.frame(maxWidth: .infinity,alignment : .leading)
    }
}

struct UpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeView(showSuccessToast: .constant(false), showErrorToast: .constant(false))
    }
}
