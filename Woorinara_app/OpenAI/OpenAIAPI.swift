//
//  OpenAIAPI.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 28.11.2023.
//

import Foundation
import GPTEncoder
import CommonCrypto
import CryptoKit
import Firebase

#if os(Linux)
import AsyncHTTPClient
import FoundationNetworking
import NIOFoundationCompat
#endif

public class OpenAIAPI: @unchecked Sendable {
    
    public enum Constants {
        public static let defaultModel = "gpt-3.5-turbo-1106"
        public static let defaultSystemText = "You're a helpful assistant"
        public static let defaultTemperature = 0.5
    }
    
    private let urlString = "https://api.openai.com/v1"
    private let gptEncoder = GPTEncoder()
    public private(set) var historyList = [Message]()
    
    
    
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    
    
    var apiKey: String = ""
    
    init() {
        let db = Firestore.firestore()
        let docRef = db.collection("app").document("app_info")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists,
               let data = document.data(),
               let fetchedApiKey = data["api_key"] as? String {
                self.apiKey = fetchedApiKey
            } else {
                print("Error fetching API key: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func getApiKey() async -> String {
        let db = Firestore.firestore()
        let docRef = db.collection("app").document("app_info")
        
        do {
            let document = try await docRef.getDocument()
            if let data = document.data(), let apiKey = data["api_key"] as? String {
                return apiKey
            }
        } catch {
            print("Error fetching document: \(error)")
        }
        return ""
    }
    
    
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.apiKey)"
        ]
    }
    
    
    private func systemMessage(content: String) -> Message {
        .init(role: "system", content: content)
    }
    
    
    private func generateMessages(from text: String, systemText: String) -> [Message] {
        var messages = [systemMessage(content: systemText)] + historyList + [Message(role: "user", content: text)]
        if gptEncoder.encode(text: messages.content).count > 4096  {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text, systemText: systemText)
        }
        return messages
    }
    
    private func jsonBody(text: String, model: String, systemText: String, temperature: Double, stream: Bool = true) throws -> Data {
        let request = Request(model: model,
                              temperature: temperature,
                              messages: generateMessages(from: text, systemText: systemText),
                              stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(Message(role: "user", content: userText))
        self.historyList.append(Message(role: "assistant", content: responseText))
    }
    
#if os(Linux)
    private let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    private var clientRequest: HTTPClientRequest {
        var request = HTTPClientRequest(url: "\(urlString)/chat/completions")
        request.method = .POST
        headers.forEach {
            request.headers.add(name: $0.key, value: $0.value)
        }
        return request
    }
    
    
    public func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var request = self.clientRequest
        request.body = .bytes(try jsonBody(text: text, stream: true))
        
        let response = try await httpClient.execute(request, timeout: .seconds(25))
        
        guard response.status == .ok else {
            var data = Data()
            for try await buffer in response.body {
                data.append(.init(buffer: buffer))
            }
            var error = "Bad Response: \(response.status.code)"
            if data.count > 0, let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        return AsyncThrowingStream<String, Error> {  continuation in
            Task(priority: .userInitiated) { [weak self] in
                do {
                    var responseText = ""
                    for try await buffer in response.body {
                        let line = String(buffer: buffer)
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self?.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    self?.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func sendMessage(text: String,
                            model: String = ChatGPTAPI.Constants.defaultModel,
                            systemText: String = ChatGPTAPI.Constants.defaultSystemText,
                            temperature: Double = ChatGPTAPI.Constants.defaultTemperature) async throws -> String {
        var request = self.clientRequest
        request.body = .bytes(try jsonBody(text: text, model: model, systemText: systemText, temperature: temperature, stream: false))
        
        let response = try await httpClient.execute(request, timeout: .seconds(25))
        
        var data = Data()
        for try await buffer in response.body {
            data.append(.init(buffer: buffer))
        }
        
        guard response.status == .ok else {
            var error = "Bad Response: \(response.status.code)"
            if data.count > 0, let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
        
    }
    
    deinit {
        let client = self.httpClient
        Task.detached { try await client.shutdown() }
        
    }
#else
    
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "\(urlString)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    public func sendMessageStream(text: String,
                                  model: String = OpenAIAPI.Constants.defaultModel,
                                  systemText: String = OpenAIAPI.Constants.defaultSystemText,
                                  temperature: Double = OpenAIAPI.Constants.defaultTemperature) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, model: model, systemText: systemText, temperature: temperature)
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            throw "Bad Response: \(httpResponse.statusCode). \(errorText)"
        }
        
        return AsyncThrowingStream<String, Error> {  continuation in
            Task(priority: .userInitiated) { [weak self] in
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self?.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    self?.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func sendMessage(text: String,
                            model: String = OpenAIAPI.Constants.defaultModel,
                            systemText: String = OpenAIAPI.Constants.defaultSystemText,
                            temperature: Double = OpenAIAPI.Constants.defaultTemperature) async throws -> String {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, model: model, systemText: systemText, temperature: temperature, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
#endif
    
    public func deleteHistoryList() {
        self.historyList.removeAll()
    }
    
    public func replaceHistoryList(with messages: [Message]) {
        self.historyList = messages
    }
    
    func fetchModeration(inputText: String) async throws -> Bool {
        guard let url = URL(string: "\(urlString)/moderations") else {
            print("Invalid URL")
            return false
        }
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let parameters = ["input": inputText]
        
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        print(jsonData)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON string: \(jsonString)")
            }
            
            
            print(jsonData)
            
            let result = try JSONDecoder().decode(ModerationResult.self, from: data)
            print(data)
            // Check if any of the categories is flagged
            if let flagged = result.results.first?.categories.values.contains(true) {
                return flagged
            }
            
            return false
            
        } catch {
            
            print("Error: \(error)")
            throw error
        }
    }
    
    func generateImage(prompt: String) async throws -> GeneratedImage {
        guard let url = URL(string: "\(urlString)/images/generations") else {
            print("Invalid URL")
            throw "Invalid URL"

        }
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        
        let parameters = Parameters(model: "dall-e-3", n: 1, prompt: prompt, size: "1024x1024")

        let jsonData = try JSONEncoder().encode(parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        print(jsonData)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON string: \(jsonString)")
            }
            
            
            print(jsonData)
            
            let result = try JSONDecoder().decode(GeneratedImage.self, from: data)
            print(data)
            // Check if any of the categories is flagged
     
            
            return result
            
        } catch {
            
            print("Error: \(error)")
            throw error
        }
    }
    
    func generateVoice(prompt: String, selectedVoice: String) async throws -> Data {
        guard let url = URL(string: "\(urlString)/audio/speech") else {
            throw "Invalid URL"
        }

        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let parameters = VoiceRequestBody(model: "tts-1", input: prompt, voice: selectedVoice)
        let jsonData = try JSONEncoder().encode(parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            throw error
        }
    }

    
 

}

 
