//
//  FirebaseAuthService.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit
import AuthenticationServices
import CryptoKit

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private init() {}
    
    // MARK: - Nonce Generation for Apple Sign-In
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in UInt8.random(in: 0...255) }
            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    // MARK: - Google Sign-In
    
    @MainActor
    func signInWithGoogle(presenting: UIViewController) async throws -> String {
        // Use the client ID directly from GoogleService-Info.plist
        let clientID = "614687153224-hasln2temb3ifgljjk563ik9cp3iljn4.apps.googleusercontent.com"
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "No Google credential", code: -2)
        }
        
        // Create Firebase credential from Google token
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        
        // Sign in to Firebase with Google credential
        let authResult = try await Auth.auth().signIn(with: credential)
        let uid = authResult.user.uid
        
        // Get user info from Google
        let user = result.user
        let email = user.profile?.email ?? "unknown@example.com"
        let name = user.profile?.name ?? "Google User"
        
        // Store user info in Firestore
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        try await userRef.setData([
            "name": name,
            "email": email,
            "provider": "google",
            "createdAt": Timestamp(date: Date())
        ], merge: true)
        
        return uid
    }
    
    // MARK: - Apple Sign-In
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> String {
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "No Apple ID token", code: -3)
        }
        
        // Create Firebase credential from Apple token
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        // Sign in to Firebase with Apple credential
        let authResult = try await Auth.auth().signIn(with: firebaseCredential)
        let uid = authResult.user.uid
        
        // Get user info from Apple (may be nil if user already signed in before)
        let fullName = credential.fullName
        let email = credential.email ?? authResult.user.email ?? "unknown@example.com"
        let displayName = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        let name = displayName.isEmpty ? "Apple User" : displayName
        
        // Store user info in Firestore (only if new user or email/name available)
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        // Check if user already exists
        let document = try await userRef.getDocument()
        
        if !document.exists {
            // New user - create document
            try await userRef.setData([
                "name": name,
                "email": email,
                "provider": "apple",
                "createdAt": Timestamp(date: Date())
            ])
        } else if credential.email != nil || !displayName.isEmpty {
            // Existing user but we got new info from Apple - merge it
            try await userRef.setData([
                "name": name,
                "email": email,
                "provider": "apple"
            ], merge: true)
        }
        
        return uid
    }
    
    // MARK: - Sign Out
    
    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - Get Current User ID
    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
