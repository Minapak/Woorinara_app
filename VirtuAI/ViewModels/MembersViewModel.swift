//
//  UserViewModel.swift
//  VirtuAI
//
//  Created by 박은민 on 10/23/24.
//

import Foundation

// Define a User structure that reflects the updated JSON schema.
struct Members: Codable {
    var username: String
    var nickname: String
    var email: String
    var phoneNumber: String
    var residentialType: String
    var annualIncome: Int
    var workplaceName: String
    var workplaceRegistrationNumber: String
    var workplacePhoneNumber: String
    var profileImageUrl: String
    var signatureUrl: String
    var status: String
    var role: String
}

// ResponseWrapper now should handle a single User object, not a list.
struct ResponseWrapper<T: Decodable>: Decodable {
    let status: Int
    let message: String
    let data: T
}

class MembersViewModel {
    @Published var members: Members?

    init() {
        fetchMembers()
    }
    
    func fetchMembers() {
        // Example JSON data, now reflecting a single user object structure.
        let exampleUserDataJSON = """
        {
            "status": 200,
            "message": "SUCCESS",
            "data": {
                "username": "leeseokwoon",
                "nickname": "lso55071",
                "email": "leeseokwoon@gmail.com",
                "phoneNumber": "010-1234-5678",
                "residentialType": "Apartment",
                "annualIncome": 50000000,
                "workplaceName": "Example Corp",
                "workplaceRegistrationNumber": "1234567890",
                "workplacePhoneNumber": "010-9876-5432",
                "profileImageUrl": "https://example.com/profile.jpg",
                "signatureUrl": "https://example.com/signature.jpg",
                "status": "STATUS_NORMAL",
                "role": "ROLE_MEMBER"
            }
        }
        """

        let jsonData = Data(exampleUserDataJSON.utf8)
        do {
            let response = try JSONDecoder().decode(ResponseWrapper<Members>.self, from: jsonData)
            if response.status == 200 {
                self.members = response.data
            } else {
                print("Failed to fetch user: \(response.message)")
            }
        } catch {
            print("Error decoding user data: \(error)")
        }
    }
    
    func saveMembers(members: Members) {
        // Here, we'll simply assign the user to the published variable.
        self.members = members
        print("User updated or saved successfully")
    }
    
    func updateMembers(members: Members) {
        saveMembers(members: members)
    }
    
    func getMembers(completion: @escaping (Result<Members, Error>) -> Void) {
        // Simulate fetching the user asynchronously
        DispatchQueue.main.async {
            if let members = self.members {
                completion(.success(members))
            } else {
                let error = NSError(domain: "Members not found", code: 404, userInfo: nil)
                completion(.failure(error))
            }
        }
    }
}
