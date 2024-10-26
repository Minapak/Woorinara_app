//
//  FirebaseViewModel.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 28.11.2023.
//

import Firebase
import FirebaseAuth

class FirebaseViewModel {
    var apiKey: String = ""
    let firestore = Firestore.firestore()
    
    init() {
     
        let docRef = firestore.collection("app").document("app_info")

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
    
    

    func saveUser(user: User) {
           let usersCollection = firestore.collection("users")
           usersCollection.whereField("email", isEqualTo: user.email)
               .getDocuments { snapshot, error in
                   guard let snapshot = snapshot, error == nil else {
                       print("Error fetching documents: \(error!)")
                       return
                   }
                   
                   if snapshot.isEmpty {
                       // User does not exist, add them to the database
                       var ref: DocumentReference? = nil
                       ref = usersCollection.addDocument(data: user.dictionary) { err in
                           if let err = err {
                               print("Error adding document: \(err)")
                           } else {
                               let newUserRef = ref!
                               usersCollection.document(newUserRef.documentID).updateData(["id": newUserRef.documentID]) { err in
                                   if let err = err {
                                       print("Error updating document: \(err)")
                                   } else {
                                       print("User saved successfully with ID: \(newUserRef.documentID)")
                                   }
                               }
                           }
                       }
                   } else {
                       // User already exists
                       print("User already exists")
                   }
               }
       }

       func updateCredit(remainingMessageCount: Int) {
           let usersCollection = firestore.collection("users")
           usersCollection.whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "")
               .getDocuments { snapshot, error in
                   guard let snapshot = snapshot, error == nil else {
                       print("Error fetching documents: \(error!)")
                       return
                   }

                   if !snapshot.isEmpty {
                       let userDoc = snapshot.documents.first!
                       userDoc.reference.updateData(["remainingMessageCount": remainingMessageCount]) { err in
                           if let err = err {
                               print("Error updating document: \(err)")
                           } else {
                               print("User updated successfully")
                           }
                       }
                   } else {
                       print("User not found for updating")
                       let newUser = User(id: "", email: Auth.auth().currentUser?.email ?? "", isProUser: false, remainingMessageCount: Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT)
                       self.saveUser(user: newUser)
                   }
               }
       }
    
    func updateProVersion(isPro: Bool) {
        let usersCollection = firestore.collection("users")
        usersCollection.whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "")
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                if !snapshot.isEmpty {
                    let userDoc = snapshot.documents.first!
                    userDoc.reference.updateData(["isProUser": isPro]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("User updated successfully")
                        }
                    }
                } else {
                    print("User not found for updating")
                    let newUser = User(id: "", email: Auth.auth().currentUser?.email ?? "", isProUser: false, remainingMessageCount: Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT)
                    self.saveUser(user: newUser)
                }
            }
    }
    
    func updateUser(user: User) {
        let usersCollection = firestore.collection("users")
        usersCollection.whereField("email", isEqualTo: user.email)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                if !snapshot.isEmpty {
                    let userDoc = snapshot.documents.first!
                    userDoc.reference.updateData(["remainingMessageCount": user.remainingMessageCount, "isProUser": user.isProUser]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("User updated successfully")
                        }
                    }
                } else {
                    print("User not found for updating")
                    self.saveUser(user: user)
                }
            }
    }
    
    func getUser( completion: @escaping (Result<User, Error>) -> Void) {
        let usersCollection = firestore.collection("users")
        usersCollection.whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "")
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error fetching documents: \(error!)")
                    completion(.failure(error!))
                    return
                }

                if !snapshot.isEmpty {
                    let userDoc = snapshot.documents.first!
                    let data = userDoc.data() // Directly use the data here

                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        completion(.success(user))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    let newUser = User(id: "", email: Auth.auth().currentUser?.email ?? "", isProUser: false, remainingMessageCount: Constants.Preferences.FREE_MESSAGE_COUNT_DEFAULT)
                    self.saveUser(user: newUser)
                    completion(.failure(NSError(domain: "User not found", code: 404, userInfo: nil)))
                }
            }
    }


    
    
}
