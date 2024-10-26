//
//  AlertViewModel.swift
//  VirtuAI
//
//  Created by 박은민 on 10/15/24.


import SwiftUI
import AlertToast

class AlertViewModel: ObservableObject {
    
    @Published var show = false
    @Published var alertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "SOME TITLE"){
        didSet{
            show.toggle()
        }
    }
    
    func toggle() {
        show.toggle()
    }
    
    @Published var showAlert = false
    @Published var errorMessage = "" {
        didSet {
            showAlert.toggle()
        }
    }
}

class AppStateStorage: ObservableObject {
  //  @Published var selectedUser: UserListResponseData?
}


