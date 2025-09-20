//
//  VoiceViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.12.2023.
//


import Foundation
import Combine
import SwiftUI
//import AVFoundation
import AVKit

class VoiceViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let api = OpenAIAPI()
    
    @Published  var isGenerated: Bool = false
    @Published  var selectedImage: String = "Alloy"
    @Published  var selectedValue: String = "alloy"
    @Published  var playingVoice: String = ""
    @Published  var selectedPrompt: String = ""
    @Published var isLoading: Bool = false
    @Published var isPlayingFromURL: Bool = false
    
    @Published var showAdsAndProVersion = false
    @Published var isDownloading: Bool = false
    @Published var freeMessageCount: Int = UserDefaults.freeMessageCount
    private var firebaseViewModel = FirebaseViewModel()
    var upgradeViewModel = UpgradeViewModel()
    
    var audioURLs: [String: URL] = [:]
    var audioPlayers: [String: AVAudioPlayer] = [:]
    var audioPlayer: AVAudioPlayer?
    var audioPlayerForURL: AVAudioPlayer?
    var currentlyPlayingFile: String?
    var currentlyPlayingFileURL: URL?
    
    @Published  var currentTime = 0.0
    @Published  var duration = 0.0
    var timer: Timer?
    
    private var timeCancel: [AnyCancellable] = []
    
    
    let voiceStylesList: [VoiceStyle] = [
        VoiceStyle(voiceName: "alloy", image: "Alloy", voice: "alloy", voiceFile: "scenic-alloy"),
        VoiceStyle(voiceName: "echo", image: "Echo", voice: "echo", voiceFile: "scenic-echo"),
        VoiceStyle(voiceName: "onyx", image: "Onyx", voice: "onyx", voiceFile: "scenic-onyx"),
        VoiceStyle(voiceName: "nova", image: "Nova", voice: "nova", voiceFile: "scenic-nova"),
        VoiceStyle(voiceName: "shimmer", image: "Shimmer", voice: "shimmer", voiceFile: "scenic-shimmer"),
        
    ]
    
    override init() {
        super.init()
        loadAudioURLs()
        loadAudioFiles()
    }
    
    private func loadAudioURLs() {
        
        
        for voiceStyle in voiceStylesList {
            if let path = Bundle.main.path(forResource: voiceStyle.voiceFile, ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                audioURLs[voiceStyle.voiceFile] = url
            }
        }
    }
    
    private func loadAudioFiles() {
        for voiceStyle in voiceStylesList {
            if let path = Bundle.main.path(forResource: voiceStyle.voiceFile, ofType: "mp3"), let url = URL(string: path) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.delegate = self
                    audioPlayers[voiceStyle.voiceFile] = player
                } catch {
                    print("Error initializing AVAudioPlayer for \(voiceStyle.voiceFile): \(error)")
                }
            }
        }
    }
    
    
    func getFreeMessageCount(){
        firebaseViewModel.getUser() { result in
            switch result {
            case .success(let user):
                
                self.freeMessageCount = user.remainingMessageCount
                UserDefaults.freeMessageCount = user.remainingMessageCount
                
            case .failure(let error):
                print("Error retrieving user: \(error)")
            }
        }
    }
    
    func decreaseFreeMessageCount(){
        UserDefaults.freeMessageCount -= 1
        freeMessageCount -= 1
        
        firebaseViewModel.updateCredit(remainingMessageCount: freeMessageCount)
        
    }
    
    
    func increaseFreeMessageCount(){
        UserDefaults.freeMessageCount += Constants.Preferences.INCREASE_COUNT
        freeMessageCount += Constants.Preferences.INCREASE_COUNT
        
        firebaseViewModel.updateCredit(remainingMessageCount: freeMessageCount)
        
    }
    
    func playPauseVoice(voiceFile: String) async {
        do {
            
            DispatchQueue.main.async {
                self.playingVoice = voiceFile
            }
            
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if voiceFile == currentlyPlayingFile, audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
                audioPlayer?.currentTime = 0
                currentlyPlayingFile = nil
                DispatchQueue.main.async {
                    self.playingVoice = ""
                }
            } else {
                audioPlayer?.stop()
                
                if let player = audioPlayers[voiceFile] {
                    
                    audioPlayer = player
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    audioPlayer?.currentTime = 0
                    currentlyPlayingFile = voiceFile
                    
                } else {
                    print("Audio player for \(voiceFile) not found.")
                }
            }
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
    }
    
    
    
    // Delegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            DispatchQueue.main.async {
                self.currentlyPlayingFile = nil
                self.playingVoice = ""
                self.isPlayingFromURL = false
                print("timeee now \(self.audioPlayerForURL?.duration.rounded() ?? 0)")
                self.currentTime = self.audioPlayerForURL?.duration.rounded() ?? 0
            }
            
            stopTimer()
            
        }
    }
    
    
//    func generateVoice(prompt: String) async
//    {
//        
//        if !upgradeViewModel.isSubscriptionActive {
//            if  freeMessageCount > 0 {
//                self.decreaseFreeMessageCount()
//              
//            }else
//            {
//                DispatchQueue.main.async {
//                    withAnimation {
//                        self.showAdsAndProVersion = true
//                    }
//                }
//                return
//            }
//        }
//        
//        DispatchQueue.main.async {
//            withAnimation {
//                self.isLoading = true
//            }
//        }
//        
//        do {
//            let result = try await api.generateVoice(prompt: prompt, selectedVoice: selectedValue)
//            
//            fetchAndSaveVoiceData(from: result )
//            return
//            
//        } catch {
//            DispatchQueue.main.async {
//                withAnimation {
//                    self.isLoading = false
//                }
//            }
//        }
//        
//    }
    
    
    
    func fetchAndSaveVoiceData(from responseData: Data) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("voiceFile.mp3")
        
        do {
            try responseData.write(to: fileURL)
            
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayerForURL = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayerForURL?.delegate = self
            
            
            DispatchQueue.main.async {
                self.duration = self.audioPlayerForURL?.duration.rounded() ?? 0
                self.isLoading = false
                self.currentlyPlayingFileURL = fileURL
                self.isGenerated = true
            }
        } catch {
            print("Failed to write MP3 data to file: \(error)")
        }
    }
    
    func downloadAudio(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.main.async {
            self.isDownloading = true
        }
        let downloadTask = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success, now let's save it to the Documents directory
                do {
                    let fileManager = FileManager.default
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    // Generate a unique filename by appending a timestamp
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmss"
                    let uniqueSuffix = dateFormatter.string(from: Date())
                    let uniqueFileName = "voiceFile_\(uniqueSuffix).mp3"
                    let fileURL = documentsDirectory.appendingPathComponent(uniqueFileName)
                    
                    // Copy from temp url to documents directory
                    try fileManager.copyItem(at: tempLocalUrl, to: fileURL)
                    DispatchQueue.main.async {
                        self.isDownloading = false
                        completion(.success(fileURL))
                    }
                } catch (let writeError) {
                    DispatchQueue.main.async {
                        self.isDownloading = false
                        completion(.failure(writeError))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isDownloading = false
                    completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: nil)))
                }
            }
        }
        downloadTask.resume()
    }
    
    
    //    func downloadAudio(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    //
    //        DispatchQueue.main.async {
    //            self.isDownloading = true
    //        }
    //
    //
    //        let fileManager = FileManager.default
    //        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let fileURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
    //
    //        do {
    //
    //        try fileManager.copyItem(at: url, to: fileURL)
    //            DispatchQueue.main.async {
    //                self.isDownloading = false
    //            }
    //            completion(.success(fileURL))
    //        } catch (let writeError) {
    //            DispatchQueue.main.async {
    //                self.isDownloading = false
    //            }
    //                       DispatchQueue.main.async {
    //                           completion(.failure(writeError))
    //                       }
    //                   }
    //
    ////          let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, response, error in
    ////              if let localURL = localURL {
    ////                  DispatchQueue.main.async {
    ////                      self.isDownloading = false
    ////                  }
    ////                  completion(.success(localURL))
    ////              } else if let error = error {
    ////                  DispatchQueue.main.async {
    ////                      self.isDownloading = false
    ////                  }
    ////                  completion(.failure(error))
    ////              }
    ////          }
    ////
    ////          downloadTask.resume()
    //      }
    
    func playVoice() async {
        guard currentlyPlayingFileURL != nil else {
            print("No file to play")
            return
        }
        
        
        
        audioPlayerForURL?.play()
        DispatchQueue.main.async {
            self.isPlayingFromURL = true
        }
        startTimer()
    }
    
    func pauseVoice() {
        if audioPlayerForURL?.isPlaying == true {
            audioPlayerForURL?.pause()
            DispatchQueue.main.async {
                self.isPlayingFromURL = false
            }
            stopTimer()
        }
        
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            currentlyPlayingFile = nil
            self.playingVoice = ""
        }
    }
    
    func startTimer() {
        print("startTimer")
        stopTimer()
        DispatchQueue.main.async {
            self.updateCurrentTime()
        }
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                
                DispatchQueue.main.async {
                    self?.updateCurrentTime()
                }
                
            }
            .store(in: &timeCancel)
        
    }
    
    func stopTimer() {
        print("stopTimer")
        
        timeCancel.forEach { $0.cancel() }
        timeCancel.removeAll()
    }
    private func updateCurrentTime() {
        if let player = audioPlayerForURL, player.isPlaying {
            
            DispatchQueue.main.async {
                self.currentTime = player.currentTime.rounded()
            }
            print("Current Time Updated: \(currentTime)")
        }
    }
    
    func sliderEditingChanged(editingStarted: Bool)  {
        print("Slider editing changed: \(editingStarted)")
        if editingStarted {
            // Pause the audio if the user starts dragging the slider
            pauseVoice()
        } else {
            // Set the audio player's current time and resume playing if it was playing before
            if let player = audioPlayerForURL {
                player.currentTime = currentTime.rounded()
                if isPlayingFromURL {
                    Task {
                        await playVoice()
                    }
                    
                }
            }
        }
    }
    
    
}
