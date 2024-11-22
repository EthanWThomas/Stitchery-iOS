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

struct ChatRoomUser {
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
    
    func getCurrentUser() -> ChatRoomUser? {
        guard let authUser = auth.currentUser else {
            return nil
        }
        
        return ChatRoomUser(Uid: authUser.uid, name: authUser.displayName ?? "Unknown", email: authUser.email, photoURL: authUser.photoURL?.absoluteString)
    }
    
    func SignInWithGoogle(completion: @escaping (Result<ChatRoomUser, GoogleSignInError>) -> Void) {
        let clientID = "437729671182-jknbju9l9tdt27je4an79k66810pdd5f.apps.googleusercontent.com"
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
                let user = ChatRoomUser(Uid: result.user.uid, name: result.user.displayName ?? "Unknown", email: result.user.email, photoURL: result.user.photoURL?.absoluteString)
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}
