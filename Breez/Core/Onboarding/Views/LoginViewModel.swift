import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

@MainActor
class LoginViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    private var currentNonce: String?
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let presentingViewController = windowScene.windows.first?.rootViewController else {
                errorMessage = "Unable to find presenting view controller"
                isLoading = false
                return
            }
            
            let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let idToken = googleResult.user.idToken?.tokenString else {
                throw NSError(domain: "No Google credential", code: -2)
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleResult.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if user exists and has completed onboarding
            let userExists = await checkIfUserExistsAndHasData(uid: authResult.user.uid)
            if userExists {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
            
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Check if user exists in Firestore and has completed onboarding
    private func checkIfUserExistsAndHasData(uid: String) async -> Bool {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        do {
            let document = try await userRef.getDocument()
            if let data = document.data() {
                // Check if user has critical data fields that indicate completed onboarding
                let hasName = data["name"] != nil
                let hasEnvironmentalConcern = data["environmentalConcern"] != nil
                let hasOnboardingCompleted = data["onboardingCompletedAt"] != nil
                
                print("🔍 User exists check - hasName: \(hasName), hasEnvironmentalConcern: \(hasEnvironmentalConcern), hasOnboardingCompleted: \(hasOnboardingCompleted)")
                
                // If user has all critical data, they've completed onboarding
                return hasName && hasEnvironmentalConcern && hasOnboardingCompleted
            }
            
            print("🆕 New user - no Firestore data found")
            return false
        } catch {
            print("❌ Error checking user data: \(error)")
            return false
        }
    }
    
    // MARK: - Helper Functions
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            Task {
                await handleAppleSignIn(credential: appleIDCredential)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    private func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let nonce = currentNonce else {
                errorMessage = "Invalid state: A login callback was received, but no login request was sent."
                isLoading = false
                return
            }
            
            guard let appleIDToken = credential.identityToken else {
                errorMessage = "Unable to fetch identity token"
                isLoading = false
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = "Unable to serialize token string from data"
                isLoading = false
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )
            
            let result = try await Auth.auth().signIn(with: credential)
            
            // Check if user exists and has completed onboarding
            let userExists = await checkIfUserExistsAndHasData(uid: result.user.uid)
            if userExists {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
            
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
