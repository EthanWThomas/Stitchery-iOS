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
class AuthViewModel {
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    let auth = Auth.auth()
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    enum AuthenticationError: Error {
        case tokenError(message: String)
    }

    func getGoogleUser() -> User? {
        guard let authUser = auth.currentUser else {
            return nil
        }
        return User(id: authUser.uid, fullname: authUser.displayName ?? "Unknown", email: authUser.email ?? "Unknown", photoUrl: authUser.photoURL?.absoluteString)
    }
    
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<User, UserSignError>) -> Void) {
        let clientID = "208798065261-ts2lhecest9rrbih6l9832jpmpgcd1re.apps.googleusercontent.com"
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(.unableToGrabToVC))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [unowned self] result, error in
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
                    
            else {
                completion(.failure(.signInPressentationError))
                return
            }
            
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString)
            
            auth.signIn(with: credential) { result, error in
                guard let result = result, error == nil else {
                    completion(.failure(.authSignInError))
                    
                    return
                }
                
                let user = User(
                    id: result.user.uid,
                    fullname: result.user.displayName ?? "Unknown",
                    email: result.user.email ?? "Unknown",
                    photoUrl: result.user.photoURL?.absoluteString)
                completion(.success(user))
                self.userSession = result.user
                UserDefaults.standard.set(true, forKey: "signIn") // When this change to true, it will go to the home screen
            }
            
        }
    }
    
//    @MainActor
//      func signInWithGoogle() async -> Bool {
//          let clientID = "208798065261-ts2lhecest9rrbih6l9832jpmpgcd1re.apps.googleusercontent.com"
//          let config = GIDConfiguration(clientID: clientID)
//          GIDSignIn.sharedInstance.configuration = config
//          
////          guard let topVC = UIApplication.getTopViewController() else {
////              completion(.failure(.unableToGrabToVC))
////              return
////          }
//          
////          let config = GIDConfiguration(clientID: clientID)
////          GIDSignIn.sharedInstance.configuration = config
//          
//          guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                let window = windowScene.windows.first,
//                let rootViewController = window.rootViewController else {
//              print("There is no root view controller!")
//              return false
//          }
//          
//          do {
//              let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
//              
//              let user = userAuthentication.user
//              guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
//              let accessToken = user.accessToken
//              
//              let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
//                                                             accessToken: accessToken.tokenString)
//              
//              let result = try await Auth.auth().signIn(with: credential)
//              let firebaseUser = result.user
//             
//              print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
//              return true
//          }
//          catch {
//              print(error.localizedDescription)
//              UserDefaults.standard.set(true, forKey: "signIn") // When this change to true, it will go to the home screen
//              return false
//          }
//          
//          
//          //            let credential = GoogleAuthProvider.credential(
//          //                withIDToken: idToken,
//          //                accessToken: user.accessToken.tokenString)
//          //
//          //            auth.signIn(with: credential) { result, error in
//          //                guard let result = result, error == nil else {
//          //                    completion(.failure(.authSignInError))
//          //                    return
//          //                }
//          //
//          //                let user = User(
//          //                    id: result.user.uid,
//          //                    fullname: result.user.displayName ?? "Unknown",
//          //                    email: result.user.email ?? "Unknown",
//          //                    photoUrl: result.user.photoURL?.absoluteString)
//          //                completion(.success(user))
//          //            }
//          //        }
//          
////          Auth.auth().signIn(with: credential) { result, error in
////              guard error == nil else {
////                  completion(error)
////                  return
////              }
////              print("SIGN IN")
////              UserDefaults.standard.set(true, forKey: "signIn") // When this change to true, it will go to the home screen
////          }
//          
//      }
    
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
