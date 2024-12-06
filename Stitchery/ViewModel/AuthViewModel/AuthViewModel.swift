//
//  AuthViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/18/24.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

protocol AuthenticationFormProtocal {
    var formIsValid: Bool { get }
}

enum UserSignError: Error {
    case unableToGrabToVC
    case signInPressentationError
    case authSignInError
}

@Observable
@MainActor
class AuthViewModel{
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
//    func signInWithGoogle(completion: @escaping (Result<User, UserSignError>) -> Void) {
//        let clientID = "208798065261-ts2lhecest9rrbih6l9832jpmpgcd1re.apps.googleusercontent.com"
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        guard let topVC = UIApplication.getTopViewController() else {
//            completion(.failure(.unableToGrabToVC))
//            return
//        }
//        
//        let credent
//    }
    
    func signIn(with email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: faild to login with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // wips out User session and takes us back to login screen
            self.currentUser = nil // wips out cuurent user data model
        } catch {
            print("DEBUG: Failed to sign with error \(error.localizedDescription)")
        }
    }
    
    // MARK: Make deleteAccount function
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
