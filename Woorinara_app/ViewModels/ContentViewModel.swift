//
//  ContentViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import Foundation


class ContentViewModel : ObservableObject{
   
    init()
    {
        Appearance().overrideDisplayMode(darkTheme: UserDefaults.isDarkTheme)

    }

}
