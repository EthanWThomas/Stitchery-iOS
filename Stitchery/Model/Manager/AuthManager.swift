//
//  AuthManager.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/14/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseFirestore

struct StitcheryUser {
    let Uid: String
    let name: String
    let email: String?
    let photoURL: String?
}

enum GoogleSignInError: Error {
    case unableToGrabToVC
    case signInPressentationError
    case authSignInError
}

final class AuthManger {
    
    static let shared = AuthManger()
    
    let auth = Auth.auth()
    
    func getCurrentUser() -> StitcheryUser? {
        guard let authUser = auth.currentUser else {
            return nil
        }
        
        return StitcheryUser(Uid: authUser.uid, name: authUser.displayName ?? "Unknown", email: authUser.email, photoURL: authUser.photoURL?.absoluteString)
//        return User(id: authUser.uid, fullname: authUser.displayName ?? "Unknown", email: authUser.email ?? "Unknown", photoUrl: authUser.photoURL?.absoluteString)
    }
    
    func SignInWithGoogle(completion: @escaping (Result<StitcheryUser, GoogleSignInError>) -> Void) {
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
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            auth.signIn(with: credential) { result, error in
                guard let result = result, error == nil else {
                    completion(.failure(.authSignInError))
                    return
                }
//                let user = User(
//                    id: result.user.uid,
//                    fullname: result.user.displayName ?? "Unknown",
//                    email: result.user.email ?? "Unknown",
//                    photoUrl: result.user.photoURL?.absoluteString
//                )
//                completion(.success(user))
                let user = StitcheryUser(
                    Uid: result.user.uid,
                    name: result.user.displayName ?? "Unknown",
                    email: result.user.email,
                    photoURL: result.user.photoURL?.absoluteString)
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}
