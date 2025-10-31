//
//  AppContainerView.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AppContainerView: View {
    @StateObject private var appManager = AppManager.shared
    @State private var selectedTab: NavBar.Tab = .home
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "FFCC8E"), location: 0.23),
                        .init(color: Color(hex: "7DC7FF"), location: 0.82)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if appManager.isLoading || !appManager.isInitialized {
                    // Show loading state while initializing
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading...")
                            .font(.sohne(.bold, size: 16))
                            .foregroundColor(.white)
                    }
                } else if isLoggedIn && hasCompletedOnboarding {
                    // Main content area based on selected tab
                    ZStack {
                        switch selectedTab {
                        case .home:
                            VStack(spacing: 0) {
                                Header(currentTab: selectedTab, onLogout: { logout() })
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                if DeviceUtils.shouldUseCompactLayout {
                                    ScrollView(showsIndicators: false) {
                                        HomeView()
                                    }
                                } else {
                                    GeometryReader { geometry in
                                        ScrollView(showsIndicators: false) {
                                            HomeView()
                                                .frame(minHeight: geometry.size.height)
                                        }
                                        .scrollDisabled(geometry.size.height >= 800)
                                    }
                                }
                                NavBar(selectedTab: $selectedTab)
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, -20)
                            }
                        case .explore:
                            VStack(spacing: 0) {
                                Header(currentTab: selectedTab, onLogout: { logout() })
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                if DeviceUtils.shouldUseCompactLayout {
                                    ScrollView(showsIndicators: false) {
                                        ExploreView()
                                    }
                                } else {
                                    GeometryReader { geometry in
                                        ScrollView(showsIndicators: false) {
                                            ExploreView()
                                                .frame(minHeight: geometry.size.height)
                                        }
                                        .scrollDisabled(geometry.size.height >= 800)
                                    }
                                }
                                NavBar(selectedTab: $selectedTab)
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, -20)
                            }
                        case .reports:
                            VStack(spacing: 0) {
                                Header(currentTab: selectedTab, onLogout: { logout() })
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                if DeviceUtils.shouldUseCompactLayout {
                                    ScrollView(showsIndicators: false) {
                                        ReportsHistoryView()
                                    }
                                } else {
                                    GeometryReader { geometry in
                                        ScrollView(showsIndicators: false) {
                                            ReportsHistoryView()
                                                .frame(minHeight: geometry.size.height)
                                        }
                                        .scrollDisabled(geometry.size.height >= 800)
                                    }
                                }
                                NavBar(selectedTab: $selectedTab)
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, -20)
                            }
                        }
                    }
                    .onAppear {
                        // Removed fetchUserProgressData()
                    }
                } else if isLoggedIn && !hasCompletedOnboarding {
                    // Show onboarding when logged in but hasn't completed onboarding
                    OnboardingView(onComplete: {
                        // Mark onboarding complete for free app flow
                        hasCompletedOnboarding = true
                        checkAuthAndSubscriptionStatus(forceSync: false)
                    })
                } else {
                    // Show login when not logged in (regardless of onboarding status)
                    LoginView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            .navigationBarHidden(true) // Hide the default NavigationView bar
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenCreateFlow"))) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = .reports
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToHome"))) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = .home
            }
        }
        .overlay(alignment: .top) {
            if appManager.quizToastManager.isShowing {
                VStack {
                    ToastView(toastManager: appManager.quizToastManager)
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
        .environmentObject(appManager.quizToastManager)
        .onAppear {
            DeviceUtils.logScreenInfo()
            appManager.initialize()
            checkAuthAndSubscriptionStatus(forceSync: false)
            
            // Add Firebase Auth state listener
            _ = Auth.auth().addStateDidChangeListener { auth, user in
                print("🔐 Auth state changed - user: \(user?.uid ?? "nil")")
                DispatchQueue.main.async {
                    self.isLoggedIn = user != nil
                    print("🔐 isLoggedIn updated to: \(self.isLoggedIn)")
                }
            }
        }
        .task {
            DeviceUtils.logScreenInfo()
        }
        .onChange(of: isLoggedIn) { oldValue, newValue in
            print("🔍 isLoggedIn changed from \(oldValue) to \(newValue)")
            print("🔍 hasCompletedOnboarding: \(hasCompletedOnboarding)")
            print("🔍 isConverted: \(appManager.subscriptionManager.isConverted)")
        }
        .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
            print("🔍 hasCompletedOnboarding changed from \(oldValue) to \(newValue)")
        }
    }
    
    // MARK: - User Data Management
    
    // removed fetchUserProgressData(), checkDailyLogin(), and all progress/streak related code
    
    // MARK: - Authentication & Subscription Management
    
    private func checkAuthAndSubscriptionStatus(forceSync: Bool = false) {
        // Check if user is logged in
        let currentUser = Auth.auth().currentUser
        isLoggedIn = currentUser != nil
        
        print("🔍 checkAuthAndSubscriptionStatus:")
        print("  - isLoggedIn: \(isLoggedIn)")
        print("  - hasCompletedOnboarding: \(hasCompletedOnboarding)")
        
        // Free app: no subscription gate
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            selectedTab = .home // Reset to safe default state
            appManager.subscriptionManager.clearSubscriptionData()
            print("🚪 Logged out successfully")
            print("  - isLoggedIn: \(isLoggedIn)")
            print("  - hasCompletedOnboarding: \(hasCompletedOnboarding)")
        } catch {
            print("❌ Error signing out: \(error)")
        }
    }
}

#Preview {
    AppContainerView()
}