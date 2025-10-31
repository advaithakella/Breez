import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showingOnboarding = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "FFCC8E"), location: 0.23),
                        .init(color: Color(hex: "7DC7FF"), location: 0.82)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App branding
                    VStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Text("Welcome to")
                                .font(.proximaNovaSemibold(size: 32))
                                .foregroundColor(.white)
                                .shadow(color: Color.white.opacity(0.25), radius: 6, x: 0, y: 0)
                            Text("BREEZ")
                                .font(.frijole(size: 32))
                                .foregroundColor(.white)
                                .shadow(color: Color.white.opacity(0.25), radius: 6, x: 0, y: 0)
                        }
                        
                        Text("Join the movement to protect our planet")
                            .font(.proximaNovaSemibold(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Login options
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            // Google Sign-In
                            Button {
                                Task {
                                    await viewModel.signInWithGoogle()
                                }
                            } label: {
                                Text("Continue with Google")
                                    .font(.proximaNovaSemibold(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                    )
                                    .cornerRadius(18)
                            }
                            .disabled(viewModel.isLoading)
                        
                        }
                        
                        // Apple Sign-In
                        Button {
                            viewModel.signInWithApple()
                        } label: {
                            Text("Continue with Apple")
                                .font(.proximaNovaSemibold(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                                .cornerRadius(18)
                        }
                        .disabled(viewModel.isLoading)

                            
                            // Skip for now
                            Button {
                                showingOnboarding = true
                            } label: {
                                Text("Skip for now")
                                    .font(.proximaNovaSemibold(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                                    .underline()
                            }
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Privacy note
                    Text("We use your data only for personalization and environmental impact tracking")
                        .font(.proximaNovaSemibold(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 100)
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Signing in...")
                            .font(.proximaNovaSemibold(size: 16))
                            .foregroundColor(.white)
                    }
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        Text(errorMessage)
                            .font(.proximaNovaSemibold(size: 14))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingContainerView()
        }
        .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
            // Only show onboarding if logged in and hasn't completed onboarding
            // Otherwise, AppContainerView will handle navigation based on auth state
            if isLoggedIn && !hasCompletedOnboarding {
                showingOnboarding = true
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            // If onboarding was just completed, dismiss any onboarding views
            // AppContainerView will handle showing the main app
            if completed {
                showingOnboarding = false
            }
        }
    }
}

#Preview {
    LoginView()
}
